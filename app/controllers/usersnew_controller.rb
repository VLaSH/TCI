class UsersnewController < ApplicationController
  before_filter :require_guest_user, :except => [:photo, :instructor_photo]
  before_filter :setup_page
  def new
    #abort('d')
    
    unless session[:access_token].nil?
      client = Instagram.client(:access_token => session[:access_token])
      @usersData = client.user 
      unless (user = User.find_by(uid: @usersData.id)).nil?
        #abort(@usersData.id)
        session[:user_id] = user.id
        self.current_user = user
        flash[:notice] = 'You are now logged in'
        redirect_back_or_to(user_role_root_path)
      end
    else
      
      
      @usersData
      #@usersData = User.where(id: '3')
      #abort(@usersData.to_a.to_s)
    end
    #abort(@usersData.id)
    @user = User.new
  end

  def create   
	
    unless session[:access_token].nil?      
      client = Instagram.client(:access_token => session[:access_token])
      @usersData = client.user      
      params[:user][:uid] = @usersData.id
    end
    
    @user = User.new(params[:user])
    
    if @user.valid? && @user.register! == true
      session.delete(:access_token)
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
  def sendtest 
    UserMailer.abc().deliver 
    abort('s');
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
