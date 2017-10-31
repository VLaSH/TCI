class Instructor::ScheduledCoursesController < Instructor::BaseController

  def show
    if (@course = Course.find_by_id(params[:id])).nil?
      flash_and_redirect_to('The course you requested does not exist', :error, user_role_root_path)
    end
  end

  protected

  def setup_page
    super
    page_config do |page|
      page.body_tag_options[:id] = 'instructor'
      #page.body_tag_options[:class] = 'courses'
      page.secondary_navigation_section = :courses
      page.secondary_navigation = true
      page.tertiary_navigation_section = :lesson_plan
      page.title.unshift('Courses')
    end
  end
end
