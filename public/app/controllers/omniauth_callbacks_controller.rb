class OmniauthCallbacksController < ApplicationController

  def facebook
      @user = User.find_for_facebook(request.env["omniauth.auth"], current_user)
      if @user.persisted?
        flash[:notice] = "sucessfull authenticate with facebook"
        session[:user_id] = @user.id
        redirect_to student_root_path
      else
        render 'users/new'
      end
  end
end
