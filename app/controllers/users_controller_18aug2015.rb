class UsersController < ApplicationController

  before_filter :require_guest_user, :except => [:photo, :instructor_photo]
  before_filter :setup_page

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.valid? && @user.register! == true
      flash_and_redirect_to('Thank you for registering at The Compelling Image.', :notice, new_activation_path)
    else
      render(:action => 'new')
    end
  end

  def photo
    head(:not_found) and return if (user = User.find_by_id(params[:id])).nil?
    style = params[:style] || :original
    redirect_to(user.photo_s3_url(style))
  end

  def instructor_photo
    head(:not_found) and return if (user = User.find_by_id(params[:id])).nil?
    style = params[:style] || :original
    redirect_to(user.instructor_photo_s3_url(style))
  end

protected

  def setup_page
    page_config do |page|
      page.body_tag_options[:class] = 'sales'
      page.body_tag_options[:id] = 'register'
      page.primary_navigation_section = :register
      page.title.unshift('Sign-Up')
    end
  end

end
