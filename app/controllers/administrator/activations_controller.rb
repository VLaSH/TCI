class Administrator::ActivationsController < Administrator::BaseController

  def create
    @user = User.pending.find(params[:user_id])
    @user.activate_without_confirmation!

    if @user.activated?
      flash_and_redirect_to('You have successfully activated the user account', :notice, administrator_users_path)
    else
      render(:action => 'new')
    end

  rescue ActiveRecord::RecordNotFound
    flash_and_redirect_to('The requested user account does not exist.', :error, administrator_users_path)
  end

end