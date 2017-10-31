class Student::ScheduledCoursesController < Student::BaseController

  def index
    @scheduled_courses = ScheduledCourse.joins(:enrolments).where(enrolments: {student_user_id: current_user.id, unsubscribe: false}).group("enrolments.scheduled_course_id, enrolments.student_user_id").paginate(:per_page => 5, :page => params[:page])
  end

protected
  def setup_page
    super
    page_config do |page|
      page.body_tag_options[:class] = 'student'
      page.body_tag_options[:id] = 'scheduledcourses'
      page.secondary_navigation_section = :courses
      page.secondary_navigation = true
      page.title.unshift('Courses')
    end
  end
end
