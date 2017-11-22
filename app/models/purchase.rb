class Purchase < ActiveRecord::Base

  GATEWAYS = %w(Paypal WorldPay Stripe)
  acts_as_money

  attr_accessor :return_url, :payment_method, :description, :amount, :state, :redirect_url, :with_skype

  belongs_to :scheduled_course
  # TODO - This association needs to be checked for syntax and expected output
  belongs_to :student, -> { where('users.role IN (?)', User::ROLES[:student]) }, class_name: :User, foreign_key: :student_user_id
  has_one :enrolment, dependent: :nullify

  attr_accessible :scheduled_course, :scheduled_course_id, :gateway, :status, :with_skype

  money :price, currency: :price_currency, cents: :price_in_cents
  serialize :raw_params, Hash

  validates_presence_of :scheduled_course_id, :student_user_id, :status
  validates_existence_of :scheduled_course, :student, :allow_nil => true

  validates_numericality_of :price_in_cents, greater_than: 0, only_integer: true, if: ->(p) { GATEWAYS.include?(p.gateway) }
  validates_format_of :price_currency, with: /\A[A-Z]{3}\Z/

  validates_length_of :reference, :status, maximum: 255, allow_blank: true
  validates_inclusion_of :gateway, in: GATEWAYS, message: "must be one of: #{GATEWAYS.to_sentence(words_connector: 'or')}"

  validate :student_user_must_be_a_student, :course_must_have_at_least_one_lesson
  validate :student_must_be_activated, on: :create

  delegate :course, to: :scheduled_course

  scope :pending, -> { where(:status => 'pending') }
  scope :completed, -> { where(:status => 'completed') }
  scope :paypals, -> { where(gateway: 'Paypal')}
  scope :worldpays, -> { where(gateway: 'WorldPay')}

  before_validation :set_price, on: :create

  before_validation do |p|
    p.status = p.status.to_s.mb_chars.strip.downcase.to_s
    true
  end

  before_update :create_enrolment_on_completion

  def self.process_notification!(gateway, notification_data)
    case gateway.to_s.downcase.classify
      when 'Paypal' then process_paypal_notification!(notification_data)
      when 'WorldPay' then process_world_pay_notification!(notification_data)
    else
      logger.error("Purchase#process_notification! unknown gateway: #{gateway}")
      return false
    end
  end

  def gateway_settings
    config.purchase.group(gateway.to_s.underscore.to_sym) if GATEWAYS.include?(gateway)
  end

  def create_payment(options = {})
    self.amount = ("%.2f" % price.amount)
    description = ActionView::Base.full_sanitizer.sanitize(self.course.title)
    @payment = case gateway
    when 'Paypal'
      Payment.new( :order => self )
    when 'WorldPay'
      WorldPay.new(student.details.merge(amount: self.price_in_cents, return_url: self.return_url, description: description))
    when 'Stripe'
      customer = Stripe::Customer.create(:email => options[:stripeEmail],:card  => options[:stripeToken])
      charge = Stripe::Charge.create(
        :customer    => customer.id,
        :amount      => self.price_in_cents,
        :description => description,
        :currency    => 'usd'
      )
    else
      nil
    end
    if @payment.try(:create)
      self.payment_id = @payment.id
      self.state = @payment.state
      self.redirect_url = @payment.approve_url if self.worldpay?
      save
    elsif charge
      self.payment_id = @payment.id
      self.status = @payment.status
      save
    else
      case gateway
      when 'Paypal'
        errors.add :payment_method, @payment.error["message"] if @payment.error
      when 'WorldPay'
        errors.add :payment_method, @payment.errors.full_messages.join(', ')
      when 'Stripe'
        errors.add :payment_method, "Sorry..! payment failed."
      end
    end
  end

  def payment
    @payment = case gateway
    when 'Paypal'
      @payment || payment_id && Payment.find(payment_id)
    when 'WorldPay'
      WorldPay.new(student.details.merge(amount: self.price_in_cents, order_id: self.payment_id))
    end
  end

  def approve_url
    if paypal?
      payment.links.find{|link| link.method == "REDIRECT" }.try(:href)
    elsif worldpay?
      self.redirect_url
    end
  end


  def set_price
    self.price = course.current_price(student_user_id, with_skype).exchange_to(gateway_settings.currency) unless scheduled_course.nil?
    true
  end

  # refunding Amount.
  def refund
    refund_amount = ("%.2f" % (price.amount * 0.9))
    refund = case gateway
             when 'Paypal'
               payment.sale.refund({
                 :amount => {
                   :total => refund_amount,
                   :currency => "USD"
                 }
               })
             when 'WorldPay'
               payment.make_refund
             when 'Stripe'
               charge = Stripe::Charge.retrieve(self.payment_id)
               charge.refund
             end
    refunded = case gateway
      when 'Paypal'
        refund.success?
      when 'Stripe'
        refund.refunded
      end
    if refunded
      enrolment.update_column(:unsubscribe, true)
      enrolment.scheduled_lessons.each do |esl|
        esl.update_column(:deleted_at, Time.now)
        esl.scheduled_assignments.update_all(deleted_at: Time.now)
      end
      true
    else
      false
    end
  end

  GATEWAYS.each do |gw|
    define_method("#{gw.to_s.downcase}?") do
      gw == gateway
    end
  end

  protected

    def student_user_must_be_a_student
      errors.add(:student, 'must be a student user') unless student.nil? || student.student?
    end

    def student_must_be_activated
      errors.add(:student, 'must be activated') unless student.nil? || student.activated?
    end

    def course_must_have_at_least_one_lesson
      if scheduled_course
        errors.add(:course, 'must have at least one lesson') if !course.nil? && course.lessons.size.zero?
      end
    end

    def create_enrolment_on_completion
      if status_changed? && status == 'completed'
        existing_enrolment = Enrolment.where('student_user_id = ? and scheduled_course_id = ? and unsubscribe = ? and end_date >= ?', student.id, scheduled_course.id, false, Time.zone.now.end_of_day).last
        e = build_enrolment(student: student)
        e.parent_id = existing_enrolment.id if existing_enrolment
        e.purchase = self
        e.scheduled_course = scheduled_course
        e.save
      else
        true
      end
    end
  end
