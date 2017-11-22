class EnquiriesController < ApplicationController
  before_filter :setup_page
  def new
    @enquiry = Enquiry.new
  end  
  
  def create
    @enquiry = Enquiry.new(params[:enquiry])
  
    if @enquiry.save
      redirect_to submitted_enquiries_path
    else
      render :action => "new"
    end
  end
  
  def submitted
  end
  
protected

  def setup_page
    page_config do |page|
      page.body_tag_options = { :class => 'sales', :id => 'contact' }
      page.primary_navigation_section = :contact
      page.title.unshift('Contact')
    end
  end
end