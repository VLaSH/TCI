# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
	
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  def set_currency
   session[:currency] = params[:currency]
   p session[:currency]
   redirect_to :back
  end

  helper_method :current_user, :current_user?, :logged_in?, :user_role_root_path
	    
    protected

    def current_user
      @current_user ||= (login_using_session || :guest)
    end

    def current_user=(new_user)
      session[:user_id] = new_user.is_a?(User) ? new_user.id : nil
      @current_user = new_user
    end

    def current_user?(user)
      current_user == user
    end

    def logged_in?
      current_user.is_a?(User) && current_user.activated?
    end

    def logout
      reset_session
      flash_and_redirect_to('You have been logged out.', :notice, root_path)
    end

    def require_logged_in_user
      unless logged_in?
        remember_current_location
        redirect_to(login_path)
      end
    end

    def require_guest_user
      redirect_to(courses_path) if logged_in?
    end

    User::ROLES.keys.each do |role|
      define_method("require_#{role}_user") do
        if logged_in?
          redirect_path = user_role_root_path
        else
          remember_current_location
          redirect_path = login_path
        end

        flash_and_redirect_to("You have to be a registered to access the Student Administration Panel. If you want to enroll on a course please register and sign in with your details.", :error, redirect_path) unless logged_in? && current_user.send("#{role}?")
      end
    end

    def user_role_root_path
      case
        when !logged_in? then root_path
        when current_user.student? then student_root_path
        when current_user.instructor? then instructor_root_path
        when current_user.administrator? then administrator_root_path
      end
    end

    def remember_current_location
      session[:return_to_location] = request.url
    end

    def redirect_back_or_to(default)
      redirect_to(session[:return_to_location] || default)
      session[:return_to_location] = nil
    end

    def flash_and_redirect_to(msg, key, *params)
      flash[key] = msg
      redirect_to(*params)
    end

    def redirect_if_page_out_of_bounds(collection)
      redirect_to(:overwrite_params => { :page => collection.total_pages }) if !collection.total_pages.zero? && collection.out_of_bounds?
    end

    def normalise_params
      params.traverse! { |key, value| [ key, normalise_param_value(value) ] }
    end

    def set_time_zone_for_current_user
      Time.zone = current_user.time_zone if logged_in?
    end

  private

    def login_using_session
      session[:user_id].nil? ? nil : User.authenticate_by_id(session[:user_id])
    end


end
