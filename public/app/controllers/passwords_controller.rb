class PasswordsController < ApplicationController

  before_filter :require_guest_user
  before_filter :setup_page
  
  def new
  end

  def create
    @email = params[:email].to_s
    if User.reset_password(params[:email])
      flash_and_redirect_to('Your password has been reset - please check your email for your temporary password', :notice, login_path)
    else
      flash.now[:error] = 'Email address is invalid'
      render(:action => 'new')
    end
  end

  protected
    
    def setup_page
      page_config do |page|
        page.body_tag_options[:class] = 'sales'
        page.body_tag_options[:id] = 'password'
        page.primary_navigation_section = :login
        page.title.unshift('Password Reset')
      end
    end
end