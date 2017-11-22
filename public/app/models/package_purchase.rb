class PackagePurchase < ActiveRecord::Base
  GATEWAYS = %w(Paypal WorldPay)
  acts_as_money

  belongs_to :package
  # TODO - This assocaition needs to be checked for syntax and valid association
  belongs_to :student, -> { where('users.role IN (?)', User::ROLES[:student]) }, class_name: :User, foreign_key: :student_user_id

  has_many :enrolments, dependent: :nullify

  attr_accessible :package, :package_id, :gateway

  money :price, currency: :price_currency
  serialize :raw_params, Hash

  validates_presence_of :package_id, :student_user_id, :status
  validates_existence_of :package, :student, allow_nil: true

  # validates_numericality_of :price_in_cents, greater_than: 0, only_integer: true, if: Proc.new { |p| GATEWAYS.include?(p.gateway) }
  validates_numericality_of :price_in_cents, greater_than: 0, only_integer: true, if: -> (p) {GATEWAYS.include?(p.gateway) }
  validates_format_of :price_currency, with: /\A[A-Z]{3}\Z/

  validates_length_of :reference, :status, maximum: 255, allow_blank: true
  validates_inclusion_of :gateway, in: GATEWAYS, message: "must be one of: #{GATEWAYS.to_sentence(words_connector: 'or')}"

  validate :student_user_must_be_a_student
  validate :package_must_be_enrollable, :student_must_be_activated, on: :create

  delegate :courses, to: :package

  scope :pending, -> { where(:status => 'pending') }
  scope :completed, -> { where(:status => 'completed') }

  before_validation :set_price, on: :create



  before_validation do |p|
    p.status = p.status.to_s.mb_chars.strip.downcase.to_s
    true
  end

  before_update :create_enrolments_on_completion

  def self.process_notification!(gateway, notification_data)
    case gateway.to_s.downcase.classify
      when 'Paypal' then process_paypal_notification!(notification_data)
      when 'WorldPay' then process_world_pay_notification!(notification_data)
    else
      logger.error("PackagePurchase#process_notification! unknown gateway: #{gateway}")
      return false
    end
  end

  def set_price
    p.price = p.package.price.exchange_to(p.gateway_settings.currency) unless p.package.nil? || p.gateway_settings.nil?
    true
  end

  def gateway_settings
    config.purchase.group(gateway.to_s.underscore.to_sym) if GATEWAYS.include?(gateway)
  end

  protected

    def student_user_must_be_a_student
      errors.add(:student, 'must be a student user') unless student.nil? || student.student?
    end

    def student_must_be_activated
      errors.add(:student, 'must be activated') unless student.nil? || student.activated?
    end

    def package_must_be_enrollable
      errors.add(:package, 'cannot be enrolled on at this time') unless package.nil? || package.available?
    end

    def create_enrolments_on_completion
      if status_changed? && status == 'completed'
        package.scheduled_courses.each do |scheduled_course|
          e = Enrolment.new(scheduled_course: scheduled_course, student: student)
          e.package_purchase = self
          e.scheduled_course = scheduled_course
          e.save
        end
      else
        true
      end
    end

  private

    def self.process_paypal_notification!(notification_data)
      if (notification = ActiveMerchant::Billing::Integrations::Paypal::Notification.new(notification_data)).acknowledge
        logger.error("Paypal notification account mismatch: expected #{config.purchase.paypal.account.downcase} got #{notification.account}") and return false unless notification.account.to_s.downcase == config.purchase.paypal.account.to_s.downcase

        logger.error("Paypal notification purchase not found (ID: #{notification.item_id})") and return if (purchase = pending.find_by_id(notification.item_id)).nil?

        logger.error("Paypal notification purchase gateway mismatch: got #{purchase.gateway}") and return unless purchase.gateway == 'Paypal'

        if notification.complete?
          if notification.gross_cents == purchase.price_in_cents
            if notification.currency.to_s.downcase == purchase.price_currency.to_s.downcase
              purchase.status = 'completed'
            else
              logger.error("Paypal notification currency mismatch: expected #{purchase.price_currency} got #{notification.currency}")
              purchase.status = 'error'
            end
          else
            logger.error("Paypal notification amount (cents) mismatch: expected #{purchase.price_in_cents} got #{notification.gross_cents}")
            purchase.status = 'error'
          end
        else
          purchase.status = notification.status
        end
        purchase.raw_params = notification.params
        purchase.reference = notification.transaction_id
        purchase.notification_received_at = notification.received_at
        purchase.save!
      else
        logger.error("Paypal notification acknowledgement failed (account: #{notification.account} reference: #{notification.transaction_id})")
      end
    end

    def self.process_world_pay_notification!(notification_data)
      if (notification = ActiveMerchant::Billing::Integrations::WorldPay::Notification.new(notification_data)).acknowledge
        logger.error("WorldPay notification account mismatch: expected #{config.purchase.world_pay.account.downcase} got #{notification.account}") and return false unless notification.account.to_s.downcase == config.purchase.world_pay.account.to_s.downcase

        logger.error('WorldPay notification security key mismatch') and return false unless notification.security_key == config.purchase.world_pay.security_key

        logger.error("WorldPay notification purchase not found (ID: #{notification.item_id})") and return if (purchase = pending.find_by_id(notification.item_id)).nil?

        logger.error("WorldPay notification purchase gateway mismatch: got #{purchase.gateway}") and return unless purchase.gateway == 'WorldPay'

        if notification.complete?
          if notification.gross_cents == purchase.price_in_cents
            if notification.currency.to_s.downcase == purchase.price_currency.to_s.downcase
              purchase.status = 'completed'
            else
              logger.error("WorldPay notification currency mismatch: expected #{purchase.price_currency} got #{notification.currency}")
              purchase.status = 'error'
            end
          else
            logger.error("WorldPay notification amount (cents) mismatch: expected #{purchase.price_in_cents} got #{notification.gross_cents}")
            purchase.status = 'error'
          end
        else
          purchase.status = notification.status
        end
        purchase.raw_params = notification.params
        purchase.reference = notification.transaction_id
        purchase.notification_received_at = notification.received_at
        purchase.save!
      else
        logger.error("WorldPay notification acknowledgement failed (account: #{notification.account} reference: #{notification.transaction_id})")
      end
    end
end
