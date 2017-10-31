class SessionsController < ApplicationController

  # filter_parameter_logging :password
  before_filter :require_guest_user, :only => [ :new, :create ]
  before_filter :setup_page

  def new
    @user = User.new
  end

  def create
    @email = params[:email].to_s
    password = params[:password].to_s
    password_reset = false

    if (user = User.authenticate_by_email_and_password(@email, password)).nil?
      user = User.authenticate_by_email_and_temporary_password(@email, password)
      password_reset = true
    end

    case
      when user.nil? then failed_login('Your login details are invalid')
      when user.disabled? then failed_login('Your account has been disabled')
      when user.pending? then flash_and_redirect_to('Your account has not been activated', :error, new_activation_path)
    else
      self.current_user = user
      if password_reset
        flash_and_redirect_to('Your password has been reset: you should now choose a new password', :notice, user.administrator? ? edit_administrator_user_path(user) : send("edit_#{user.role}_account_path"))
      else
        flash[:notice] = 'You are now logged in'
        redirect_back_or_to(user_role_root_path)
      end
    end
  end

  def destroy
    logout
  end

  def facebook2
      abort('test');
      #user = User.omniauth(env['omniauth.auth'])
   # session[:user_id] = user.id
   # redirect_to root_url
  end

  protected

    def failed_login(message)
      flash.now[:error] = message
      render(:action => 'new')
    end

    def setup_page
      page_config do |page|
        page.body_tag_options[:class] = 'sales'
        page.body_tag_options[:id] = 'login'
        page.primary_navigation_section = :login
        page.title.unshift('Login')
      end
    end
    
    
end
