class InstagramController < ApplicationController
  CALLBACK_URL = "http://www.thecompellingimage.com/instagram/callback"
  
  def connect
    redirect_to Instagram.authorize_url(:redirect_uri => CALLBACK_URL)
  end
  
  def callback
    response = Instagram.get_access_token(params[:code], :redirect_uri => CALLBACK_URL)
    session[:access_token] = response.access_token
    #session[:access_token] = response.access_token
    #abort(response.to_a.to_s)
    #session[:access_token] = response.access_token
    redirect_to new_user_path
  end
end
