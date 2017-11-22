class Administrator::LessonsController < Administrator::BaseController

  before_filter :find_course, :only => [ :index, :new, :create ]
  before_filter :find_lesson, :except => [ :index, :new, :create ]

  def index
    @lessons = @course.lessons.paginate(:page => params[:page], :order => 'position ASC, title ASC')
  end

  def show
  end

  def new
    @lesson = @course.lessons.build
  end

  def create
    @lesson = @course.lessons.build(params[:lesson])

    if @lesson.save
      flash_and_redirect_to('You have successfully created a new lesson', :notice, administrator_course_lessons_path(@course))
    else
      render(:action => 'new')
    end
  end

  def edit
  end

  def update
    if @lesson.update_attributes(params[:lesson])
      flash_and_redirect_to('You have successfully updated the lesson', :notice, administrator_course_lessons_path(@lesson.course))
    else
      render(:action => 'edit')
    end
  end

  def delete
  end

  def destroy
    if @lesson.delete!
      flash_and_redirect_to('Your lesson has been deleted successfully', :notice, administrator_course_lessons_path(@lesson.course))
    else
      render(:action => 'delete')
    end
  end

  protected

    def find_course
      @course = Course.non_deleted.find(params[:course_id])
    rescue ActiveRecord::RecordNotFound
      flash_and_redirect_to('The requested course does not exist', :error, administrator_courses_path)
    end

    def find_lesson
      @lesson = Lesson.non_deleted.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash_and_redirect_to('The requested lesson does not exist', :error, administrator_courses_path)
    end
    
    def setup_page
      page_config do |page|
        super
        page.secondary_navigation_section = :courses
        page.title.unshift('Lessons')
      end
    end

end