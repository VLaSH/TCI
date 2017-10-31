class Administrator::ScheduledCoursesController < Administrator::BaseController

  # before_filter :find_course, :only => [ :index, :new, :create ]
  before_filter :find_course, :only => [ :index ]
  before_filter :find_scheduled_course, :except => [ :index]

  def index
    @scheduled_courses = @course.scheduled_courses.paginate(:page => params[:page], :order => 'created_at ASC')
  end

  # def new
  #   @scheduled_course = @course.scheduled_courses.build
  # end

  # def create
  #   @scheduled_course = @course.scheduled_courses.build(params[:scheduled_course])
  #   if @scheduled_course.save
  #     flash_and_redirect_to('You have successfully created a new scheduled course', :notice, administrator_course_scheduled_courses_path(@course))
  #   else
  #     render(:action => 'new')
  #   end
  # end

  # def delete
  # end

  # def destroy
  #   if @scheduled_course.delete!
  #     flash_and_redirect_to('The scheduled course has been deleted successfully', :notice, administrator_course_scheduled_courses_path(@scheduled_course.course))
  #   else
  #     render(:action => 'delete')
  #   end
  # end

  def show
    @course = @scheduled_course.course
  end

  protected

    def find_course
      begin
        @course = Course.non_deleted.find(params[:course_id])
      rescue ActiveRecord::RecordNotFound
        flash_and_redirect_to('The requested course does not exist', :error, administrator_courses_path)
      end
    end

    def find_scheduled_course
      begin
        @scheduled_course = ScheduledCourse.non_deleted.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash_and_redirect_to('The requested scheduled course does not exist', :error, administrator_courses_path)
      end
    end

    def setup_page
      page_config do |page|
        super
        page.secondary_navigation_section = :courses
        page.title.unshift('Scheduled Courses')
      end
    end

end
