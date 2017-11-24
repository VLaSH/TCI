class UserGift < ActiveRecord::Base
  belongs_to :gift
  belongs_to :user, primary_key: :email, foreign_key: :recipient_email

  enum status: %i(pending active)

  before_create :generate_coupon_code

  attr_accessor :gateway, :return_url, :payment_method, :amount, :state, :redirect_url
  attr_accessible :status, :gateway, :recipient_name, :recipient_email, :lessons_amount, :notify_on

  delegate :price, :description, :lessons_amount, :with_skype, to: :gift

  validates :gift, :recipient_email, :recipient_name, presence: true
  validates :recipient_email, format: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/

  scope :available, -> { where(is_used: false, status: UserGift.statuses[:active]) }

  def self.check_coupon_code(coupon_code, with_skype, course)
    return {status: :error, message: 'Code length should be 6 digits'} if coupon_code.to_s.length != 6
    
    user_gift = available.find_by(coupon_code: coupon_code)
    if user_gift.present?
      unless user_gift.with_skype && ActiveRecord::Type::Boolean.new.type_cast_from_user(with_skype)
        return {status: :error, message: "Your gift works only for courses #{user_gift.with_skype ? 'with' : 'without'} \"With Skype Session\" option"}
      end
      
      case user_gift.gift.category
      when 1
        if course.lessons.count == user_gift.lessons_amount
          return {status: :ok}
        else
          return {status: :error, message: "Try course with #{user_gift.lessons_amount} lessons"}
        end
      when 4
        return {status: :ok}
      when 3
        if course.gift.present?
          return {status: :ok}
        else
          return {status: :error, message: "This coupon available only for #{user_gift.gift.course.title} course"}
        end
      else
        return {status: :error, message: 'Unexpected error'}
      end
    else
      return {status: :error, message: 'This coupon doesn\'t exist'}
    end
  end

  def self.update_by_coupon_code(coupon_code)
    user_gift = available.find_by(coupon_code: coupon_code)
    user_gift.update(is_used: true)
  end

  def create_payment(options = {})
    self.amount = ("%.2f" % gift.price.amount)

    @payment = case gateway
               when 'Paypal'
                 Payment.new(order: self)
               when 'Stripe'
                 customer = Stripe::Customer.create(:email => options[:stripeEmail], :card => options[:stripeToken])
                 charge = Stripe::Charge.create(
                   :customer => customer.id,
                   :amount => gift.price_in_cents,
                   :description => gift.description,
                   :currency => 'usd',
                 )
               else
                 nil
               end

    unless @payment.try(:create) || charge
      case gateway
      when 'Paypal'
        errors.add :payment_method, @payment.error["message"] if @payment.error
      when 'Stripe'
        errors.add :payment_method, "Sorry..! payment failed."
      end
    end
  end

  def payment
    @payment = @payment || payment_id && Payment.find(payment_id) if gateway == 'Paypal'
  end

  def approve_url
    if gateway == 'Paypal'
      payment.links.find { |link| link.method == "REDIRECT" }.try(:href)
    end
  end

  private

  def generate_coupon_code
    self.coupon_code = rand(100000..999999)
    while UserGift.exists?(["coupon_code = ?", self.coupon_code])
      self.coupon_code = rand(100000..999999)
    end
  end
end
