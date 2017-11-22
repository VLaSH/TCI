class PurchaseCompletionsController < ApplicationController

  skip_before_filter :verify_authenticity_token

  def create
    page_config do |page|
      page.body_tag_options[:class] = 'sales'
      page.body_tag_options[:id] = 'notification'
      page.primary_navigation_section = :none
      page.title.unshift('Payment Complete')
    end
    
    case params[:gateway].to_s.downcase
      when 'paypal' then render(:partial => 'paypal', :layout => 'paypal')
      when 'worldpay' then render(:partial => 'worldpay', :layout => 'worldpay')
      when 'world_pay' then render(:partial => 'worldpay', :layout => 'worldpay')  
    end
  end

end