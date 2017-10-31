class PurchaseNotificationsController < ApplicationController

  skip_before_filter :verify_authenticity_token

  def create
    page_config do |page|
      page.body_tag_options[:class] = 'sales'
      page.body_tag_options[:id] = 'notification'
      page.primary_navigation_section = :none
      page.title.unshift('Payment Complete')
    end
    
    if Purchase.process_notification!(params[:gateway], request.raw_post)
      case params[:gateway].to_s.downcase.classify
        when 'Paypal' then head(:ok)
        when 'WorldPay' then render(:partial => 'worldpay', :layout => 'worldpay')
      end
    else
      case params[:gateway].to_s.downcase.classify
        when 'Paypal' then head(:bad_request)
        when 'WorldPay' then render(:partial => 'worldpay', :layout => 'worldpay')
      end
    end
  end
  
  def test
    page_config do |page|
      page.body_tag_options[:class] = 'sales'
      page.body_tag_options[:id] = 'notification'
      page.primary_navigation_section = :none
      page.title.unshift('Payment Complete')
    end
    render(:partial => 'worldpay', :layout => 'worldpay')
  end

def paypal
      page_config do |page|
      page.body_tag_options[:class] = 'sales'
      page.body_tag_options[:id] = 'notification'
      page.primary_navigation_section = :none
      page.title.unshift('Payment Complete')
    end
   # render(:partial => 'worldpay', :layout => 'worldpay')
  end

end
