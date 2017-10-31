class PackagePurchasesController < ApplicationController

  before_filter :require_student_user, :find_package

  def new
    page_config do |page|
      page.body_tag_options[:class] = 'sales'
      page.body_tag_options[:id] = 'packages'
      page.primary_navigation_section = :packages
      page.title.unshift('New Enrollment')
    end
    @purchase = current_user.package_purchases.build
  end

  def create
    page_config do |page|
      page.body_tag_options[:class] = 'sales'
      page.body_tag_options[:id] = 'packages'
      page.primary_navigation_section = :packages
      page.title.unshift('New Enrollment')
    end
    
    if @package.free?
      if (params.has_key?(:package_id) && !params[:package_id].to_i.zero?)
        @package.scheduled_courses.each do |scheduled_course|
          e = Enrolment.new(:student => current_user)
          e.scheduled_course = scheduled_course
          e.save
        end
        
        flash_and_redirect_to('Thank you for signing up - the course will now be available in your student area', :notice, student_root_path)
      else
        flash_and_redirect_to('We were unable to enroll you on the course - please try again later', :error, student_root_path)
      end
    else
      logger.debug("in create")
      unless (@purchase = current_user.package_purchases.create(params[:package_purchase])).new_record?
        # TODO: page setup for redirect
      else
        render(:action => 'new')
      end
    end
  end

  protected

    def find_package
      @package = Package.non_deleted.find(params[:package_id].to_i)
    rescue ActiveRecord::RecordNotFound
      flash_and_redirect_to('The requested package does not exist', :error, packages_path)
    end

end