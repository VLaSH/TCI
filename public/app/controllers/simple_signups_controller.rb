class SimpleSignupsController < ApplicationController
  def create
    if params[:signup_type] == "mentorship"
      begin
        if params[:mentor] == '-- select mentor --' || params[:duration] == '-- select duration --'
          flash_and_redirect_to('You must select a mentor and duration', :notice, page_path(:mentorship))
        else
          unless ["1 month", "3 months", "6 months"].include?(params[:duration])
            flash_and_redirect_to('You must select a valid duration', :notice, page_path(:mentorship))
          else
            @item_name = params[:mentor]
            @item_number = params[:duration]
            @amount = case @item_number
              when "1 month" then 269
              when "3 months" then 649
              when "6 months" then 1279
            end
            @redirect = page_path(:signup_complete)
          end
        end
      rescue
        redirect_to page_path(:mentorship)
      end
    else
      redirect_to root_path
    end
  end
end