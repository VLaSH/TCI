class Administrator::EnrolmentsController < Administrator::BaseController

  before_filter :find_scheduled_course, :only => [ :index, :new, :create ]
  before_filter :find_enrolment, :except => [ :index, :new, :create ]
  before_filter :require_edit_permission, :only => [ :edit, :update ]

  def index
    # @enrolments = @scheduled_course.enrolments.paginate(:page => params[:page], :include => :student, :order => "#{User.quoted_table_name}.#{User.quoted_column_name('given_name')} ASC, #{User.quoted_table_name}.#{User.quoted_column_name('family_name')} ASC")
    @enrolments = @scheduled_course.enrolments.find_non_deleted_enrollments.includes(:student).order("users.given_name ASC, users.family_name ASC").page(params[:page])

  end

  def new
    @enrolment = @scheduled_course.enrolments.build
  end

  def create
    @enrolment = @scheduled_course.enrolments.build(params[:enrolment])

    if @enrolment.save
      flash_and_redirect_to('You have successfully created a new scheduled course', :notice, administrator_scheduled_course_enrolments_path(@scheduled_course))
    else
      render(:action => 'new')
    end
  end

  def edit
  end

  def update
    @enrolment.scheduled_course_id = params[:enrolment][:scheduled_course_id]
    @enrolment.duration = @enrolment.scheduled_course.course.lessons.map(&:duration).inject(:+)
    @enrolment.end_date = Time.now + @enrolment.duration.day
    if @enrolment.save
      @enrolment.update_scheduledlessons
      flash_and_redirect_to('You have successfully updated the enrollment', :notice, administrator_scheduled_course_enrolments_path(@enrolment.scheduled_course))
    else
      render(:action => 'edit')
    end
  end

  def delete
  end

  def destroy
    if @enrolment.delete!
      flash_and_redirect_to('The scheduled course has been deleted successfully', :notice, administrator_scheduled_course_enrolments_path(@enrolment.scheduled_course))
    else
      render(:action => 'delete')
    end
  end

  protected

    def find_scheduled_course
      @scheduled_course = ScheduledCourse.non_deleted.find(params[:scheduled_course_id])
    rescue ActiveRecord::RecordNotFound
      flash_and_redirect_to('The requested scheduled course does not exist', :error, administrator_courses_path)
    end

    def find_enrolment
      @enrolment = Enrolment.non_deleted.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash_and_redirect_to('The requested enrollment does not exist', :error, administrator_courses_path)
    end

    def require_edit_permission
      flash_and_redirect_to('You are not allowed to edit the enrollment', :error, administrator_scheduled_course_enrolments_path(@enrolment.scheduled_course)) unless @enrolment.editable?(current_user)
    end

    def setup_page
      page_config do |page|
        super
        page.secondary_navigation_section = :courses
        page.title.unshift('Enrolments')
      end
    end

end
