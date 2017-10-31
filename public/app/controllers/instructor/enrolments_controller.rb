class Instructor::EnrolmentsController < Instructor::BaseController

  before_filter :find_scheduled_course, :only => [ :index ]
  before_filter :find_enrolment, :except => [ :index ]

  def index
    # @enrolments = @scheduled_course.enrolments.paginate(:page => params[:page], :include => :student, :order => "#{User.quoted_table_name}.#{User.quoted_column_name('given_name')} ASC, #{User.quoted_table_name}.#{User.quoted_column_name('family_name')} ASC")
    @enrolments = @course.scheduled_course.enrolments.find_non_deleted_enrollments.joins(:student).order("given_name ASC, family_name ASC").paginate(:page => params[:page])
  end

  protected

    def find_scheduled_course
      @course = ScheduledCourse.non_deleted.find(params[:scheduled_course_id]).course
    rescue ActiveRecord::RecordNotFound
      flash_and_redirect_to('The requested scheduled course does not exist', :error, administrator_courses_path)
    end

    def find_enrolment
      @enrolment = Enrolment.non_deleted.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash_and_redirect_to('The requested enrollment does not exist', :error, administrator_courses_path)
    end

    def setup_page
      page_config do |page|
        super
        page.secondary_navigation_section = :courses
        page.tertiary_navigation_section = :enrolments
        page.title.unshift('Enrolments')
      end
    end

end
