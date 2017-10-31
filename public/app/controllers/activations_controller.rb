class ActivationsController < ApplicationController

  before_filter :require_guest_user
  before_filter :setup_page

  def new
    @user = User.new
  end

  def create
    @user = User.activate(params.slice(:user_id, :email, :password, :activation_code_confirmation))

    if @user.activated?
      self.current_user = @user
      redirect_to(user_role_root_path)
    else
      begin
        flash.now[:error] = @user.errors.full_messages.join('<br>')
      rescue
        flash.now[:error] = 'Please check your input and try again. Alternatively, try logging in.'
      end

      render(:action => 'new')
    end
  end
  
protected

  def setup_page
    page_config do |page|
      page.body_tag_options[:class] = 'sales'
      page.body_tag_options[:id] = 'register'
      page.primary_navigation_section = :login
      page.title.unshift('Sign-Up')
    end
  end

end