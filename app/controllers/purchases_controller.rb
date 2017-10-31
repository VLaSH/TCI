class PurchasesController < ApplicationController
  include PayPal::SDK::REST
  before_filter :require_student_user, :find_course
  before_filter :find_enrolment, only: [:unsubscribe]
  before_filter :can_renewable?, only: [:renew]
  before_filter :can_purchase?, only: [:new]

  def new
    page_config do |page|
      page.body_tag_options[:class] = 'sales'
      page.body_tag_options[:id] = 'courses'
      page.primary_navigation_section = :courses
      page.title.unshift('New Enrollment')
    end
    @scheduled_course_id = @course.scheduled_course.id
    @purchase = current_user.purchases.build
  end

  def renew
    page_config do |page|
      page.body_tag_options[:class] = 'sales'
      page.body_tag_options[:id] = 'courses'
      page.primary_navigation_section = :courses
      page.title.unshift('New Enrollment')
    end
    @scheduled_course_id = params[:scheduled_course]
    @purchase = current_user.purchases.build
  end

  def execute
    @purchase = Purchase.find(params[:id])
    case @purchase.gateway
    when 'Paypal'
      subscription = @purchase.payment
      if subscription.execute(:payer_id => params["PayerID"])
        @purchase.update_attributes(status: subscription.payment_status)
        redirect_to student_root_path, notice: "You have subscribed successfully."
      else
        redirect_to root_path, alert: subscription.error.inspect
      end
    when 'WorldPay'
      if @purchase.payment.make_capture
        @purchase.update_attributes(status: 'completed')
        redirect_to student_root_path, notice: "You have subscribed successfully."
      else
        redirect_to student_root_path, alert: 'Sorry..! payment failed.'
      end
    else
      redirect_to student_root_path, alert: 'Sorry..! payment method missing.'
    end
  end

  def create
    page_config do |page|
      page.body_tag_options[:class] = 'sales'
      page.body_tag_options[:id] = 'courses'
      page.primary_navigation_section = :courses
      page.title.unshift('New Enrollment')
    end
    if @course.free?
      if @course.existing_enrolment(current_user).nil?
        enrolment = Enrolment.new(:student => current_user, scheduled_course: @course.scheduled_course)
        if enrolment.save
          redirect_to student_root_path, notice: 'Thank you for signing up - the course will now be available in your student area'
        else
          redirect_to student_root_path, alert: 'We were unable to enroll you on the course - please try again later'
        end
      else
        redirect_to student_root_path, notice: 'You are already enrolled on this course'
      end
    else
      # New Paypal
      if params.has_key?(:purchase)
        if (@purchase = current_user.purchases.create(params[:purchase].merge(scheduled_course_id: @course.scheduled_course.id)))
          @purchase.return_url =  payment_execute_url(@course, @purchase)
          params[:purchase][:gateway].include?("Stripe") ? @purchase.create_payment(params) : @purchase.create_payment
          if @purchase.approve_url
            redirect_to @purchase.approve_url
          elsif @purchase.gateway.include?('Stripe')
            complete_stripe(@course, @purchase)
          else
            redirect_to root_path, alert: @purchase.errors.full_messages
          end
        else
          puts @purchase.errors.inspect
          render(:action => 'new')
        end
      else
        redirect_to new_course_purchase_path(@course), alert: 'please select any payment method ..'
      end
    end
  end

  def complete_stripe(course, purchase)
    if purchase.status.include?('succeeded')
      purchase.update_attributes(status: 'completed')
      redirect_to student_root_path, notice: "You have subscribed successfully."
    else
      redirect_to student_root_path, alert: 'Sorry..! payment failed.'
    end
  end

  def renew_subscription
    page_config do |page|
      page.body_tag_options[:class] = 'sales'
      page.body_tag_options[:id] = 'courses'
      page.primary_navigation_section = :courses
      page.title.unshift('New Enrollment')
    end
    if @course.free?
      if (permit_params.has_key?(:scheduled_course_id) && !permit_params[:scheduled_course_id].to_i.zero?)
        if Enrolment.find_by_student_user_id_and_scheduled_course_id(current_user.id, params[:scheduled_course_id]).nil?
          e = Enrolment.new(:student => current_user)
          e.scheduled_course_id = params[:scheduled_course_id]
          if e.save
            flash_and_redirect_to('Thank you for signing up - the course will now be available in your student area', :notice, student_root_path)
          else
            flash_and_redirect_to('We were unable to enroll you on the course - please try again later', :alert, student_root_path)
          end
        else
          flash_and_redirect_to('You are already enrolled on this course', :notice, student_root_path)
        end
      else
        flash_and_redirect_to('We were unable to enroll you on the course - please try again later', :alert, student_root_path)
      end
    else
      # New Paypal
      unless (@purchase = current_user.purchases.create(params[:purchase])).new_record?
        @purchase.return_url =  payment_execute_url(@course, @purchase)
        params[:purchase][:gateway].include?("Stripe") ? @purchase.create_payment(params) : @purchase.create_payment
        if @purchase.approve_url
          redirect_to @purchase.approve_url
        elsif @purchase.gateway.include?('Stripe')
          complete_stripe(@course, @purchase)
        else
          redirect_to root_path, notice: "Ops ! network error.", status: 404
        end
      else
        render(:action => 'new')
      end
    end
  end

  def unsubscribe
    if @enrolment.course_free?
      @enrolment.update_column(:unsubscribe, true)
      flash[:notice] = 'You have successfully unsubscribed course.'
    else
      if @enrolment.purchase.try(:refund)
        flash[:notice] = 'You have successfully unsubscribed course.'
      else
        flash[:alert] = 'Unable to unsubscribe, Please try once again.'
      end
    end
    redirect_to student_root_path
  end

  protected

    def can_purchase?
      if !@course.has_lessons?
        redirect_to student_root_path, alert: 'Sorry!, This course is not ready for enrolment, There are no lessons created yet.'
      elsif @course.existing_enrolment(current_user)
        redirect_to student_root_path, alert: 'Sorry, you have already enroled this Course.'
      end

    end

    # to restrict the unathorise renewal (can renew before 7 days only.)
    def can_renewable?
      if !@course.has_lessons?
        redirect_to student_root_path, alert: 'Sorry!, This course is not ready for enrolment, There are no lessons created yet.'
      elsif !@course.existing_enrolment(current_user).renewable?(current_user)
        redirect_to student_root_path, alert: "You cann't renew course, Please contact to admin."
      end
    end

    def find_enrolment
      @enrolment = Enrolment.joins(:scheduled_course).user_enrolments(current_user).where('scheduled_courses.course_id = ? AND enrolments.id = ?', params[:course_id], params[:id]).first
      if @enrolment.blank? || !@enrolment.try(:can_unsubscribe?)
        redirect_to student_root_path, alert: 'You are not authorised.'
      end
    end

    def permit_params
      @params = params.permit(:scheduled_course_id, :course_id)
    end

    def find_course
      @course = Course.non_deleted.available.find(params[:course_id])
    rescue ActiveRecord::RecordNotFound
      flash_and_redirect_to('The requested course does not exist', :alert, courses_path)
    end

    # def find_scheduled_courses
    #   # @scheduled_courses = @course.scheduled_courses.non_deleted.enrollable(current_user).all(:order => "#{ScheduledCourse.quoted_table_name}.#{ScheduledCourse.quoted_column_name('starts_on')} ASC")
    #   #@scheduled_courses = @course.scheduled_courses.non_deleted.enrollable(current_user).order("scheduled_courses.starts_on ASC")
    #   @scheduled_courses = @course.scheduled_courses.non_deleted.enrollable(current_user).order("scheduled_courses.created_at ASC")
    #   flash_and_redirect_to('No scheduled courses currently available for this course', :alert, courses_path) if @scheduled_courses.size.zero?
    # end

end
