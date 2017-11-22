class Instructor::CoursesController < Instructor::BaseController

  def index
    @all = params.has_key?(:all) && params[:all].to_i == 1
    if @all
      @scheduled_courses = ScheduledCourse.joins(:course).active.for_instructor(current_user).non_deleted.page(params[:page]).order('created_at ASC')
    else
      @scheduled_courses = ScheduledCourse.joins(:course).active.for_instructor(current_user).non_deleted.enrolled.page(params[:page]).order('created_at ASC')
    end
  end

  protected

  def setup_page
    super
    page_config do |page|
      page.body_tag_options[:id] = 'instructor'
      page.secondary_navigation_section = :courses
      page.secondary_navigation = true
      page.title.unshift('Courses')
    end
  end
end
