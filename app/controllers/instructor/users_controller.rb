class Instructor::UsersController < Instructor::BaseController

  # filter_parameter_logging :password
  helper :users

  def edit
  end

  def update
    if current_user.update_attributes(params[:user])
      flash_and_redirect_to('Your account settings have been saved', :notice, edit_instructor_account_path)
    else
      render(:action => 'edit')
    end
  end

  protected

    def setup_page
      page_config do |page|
        super
        page.secondary_navigation_section = :account
        page.title.unshift('My Account')
      end
    end

end
