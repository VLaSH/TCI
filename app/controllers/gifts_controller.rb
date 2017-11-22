class GiftsController < ApplicationController
  before_action :require_student_user, except: :index
  before_action :verify_params, except: [:index, :execute]
  before_action :gift, except: [:index, :execute]

  def index
    @gifts = Gift.all
    @testimonials = Testimonial.limit(2).order('updated_at desc')
  end

  def new
    if @gift.nil?
      redirect_to student_root_path, alert: 'Gift is unavailable'
    else
      @user_gift = @gift.user_gifts.new
    end
  end

  def create
    @user_gift = @gift.user_gifts.new(user_gift_params)
    if @user_gift.valid? && @user_gift.save
      result = process_payment
      redirect_to :back, alert: 'No gateway set' unless result
    else
      redirect_to :back, alert: @user_gift.errors.full_messages.join(' ')
    end
  end

  def execute
    @user_gift = UserGift.find(params[:gift_id])
    if params[:paymentId].present?
      complete_payment
      redirect_to student_root_path, notice: 'Gift successfully sent. Check your email for approvement.'
    else
      @user_gift.destroy
      redirect_to student_root_path, alert: 'Payment was aborted'
    end
  end

  private

  def user_gift_params
    params.require(:user_gift).permit(:gateway, :recipient_name, :recipient_email, :lessons_amount, :notify_on)
  end

  def process_payment
    gateway = params[:user_gift][:gateway]
    return false unless gateway.present?

    @user_gift.return_url = gift_execute_url(@user_gift)
    gateway.include?("Stripe") ? @user_gift.create_payment(params) : @user_gift.create_payment
    if @user_gift.approve_url
      redirect_to @user_gift.approve_url
    elsif @user_gift.gateway.include?('Stripe') && @user_gift.errors.empty?
      complete_payment
      redirect_to student_root_path, notice: 'Gift successfully sent. Check your email for approvement.'
    else
      redirect_to root_path, alert: @user_gift.errors.full_messages
    end
    true
  end

  def complete_payment
    @user_gift.active!
    GiftsMailer.notify_buyer(@user_gift, current_user).deliver_later
    GiftsMailer.notify_recipient(@user_gift).deliver_later(wait: delay_size)
  end

  def gift
    @gift ||= params[:gift_id].present? ? Gift.find_by(id: params[:gift_id]) : Gift.find_by_category_and_lessons_amount(params[:course], params[:lessons_amount])
  end

  def delay_size
    (@user_gift.notify_on - Date.today).to_int.days
  end

  def verify_params
    unless params[:gift_id].present? || (params[:course].present? && params[:lessons_amount].present?)
      redirect_to student_root_path
    end
  end
end
