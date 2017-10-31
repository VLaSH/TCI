class Administrator::CoursesController < Administrator::BaseController

  before_filter :find_course, except: [ :index, :new, :create ]
  helper :courses

  def index
    @search = params.has_key?(:search) && !params[:search].blank? ? params[:search] : nil
    @conditions = ""
    unless @search.nil?
      @conditions = "(courses.title like '%#{@search}%')"
    end

    @courses = Course.non_deleted.page(params[:page]).order('title ASC').where(@conditions)
  end

  def show
  end

  def new
    @course = Course.new
  end

  def create
    @course = Course.new(permit_params.except(:instructor_ids))
    if @course.save
      params[:course][:instructor_ids].each do |user_id|
        (@course.instructors << User.find(user_id)) unless user_id.blank?
      end
      flash_and_redirect_to('You have successfully created a new course', :notice, administrator_courses_path)
    else
      render action: :new
    end
  end

  def edit
  end

  def update
    if @course.update_attributes(permit_params)
      flash_and_redirect_to('You have successfully updated the course', :notice, administrator_courses_path)
    else
      render action: :edit
    end
  end

  def delete
  end

  def destroy
    if @course.delete!
      flash_and_redirect_to('Your course has been deleted successfully', :notice, administrator_courses_path)
    else
      render action: :delete
    end
  end

  protected

    def find_course
      @course = Course.non_deleted.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash_and_redirect_to('The requested course does not exist', :error, administrator_courses_path)
    end

    def setup_page
      page_config do |page|
        super
        page.secondary_navigation_section = :courses
        page.title.unshift('Courses')
      end
    end

    def permit_params
      params.require(:course).permit(:title, :course_type_id, :page_title, :meta_description, :meta_keywords, :available, :hidden, :portfolio_review, :hide_dates, :instant_access, :summary, :description, :price, :photo, :vimeo_video_id, :youtube_video_id, :category_1, :category_2, :category_5, :category_3, :category_4, :duration, 'starts_on(1i)', 'starts_on(2i)', 'starts_on(3i)', 'starts_on(4i)', 'starts_on(5i)', :frequency, :delete_photo, instructor_ids: [])

    end

end
