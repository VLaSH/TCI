class CoursesController < ApplicationController
  helper :users

  def select
    redirect_to course_path(params[:id])
  end

  def tag_cloud
    page_config do |page|
      page.body_tag_options[:class] = 'sales'
      page.body_tag_options[:id] = 'tag_cloud'
      page.primary_navigation_section = :courses
      page.title.unshift('Tag Cloud')
    end
  end

  def index
    page_config do |page|
      page.body_tag_options[:class] = 'sales'
      page.body_tag_options[:id] = 'courses'
      page.primary_navigation_section = :courses
      if params.has_key?(:course_type)
        page.title.unshift("Learn #{params[:course_type].titleize} Online: Enroll Today")
      else
        page.title.unshift('Photography Classes Online, Online Photography Courses, Photography Courses Online')
      end
    end

    sort_fields = {'t' => 'title ASC', 'p' => 'price_in_cents ASC'}
    @options = params
    params.delete(:action)
    params.delete(:controller)
    @tag = Tag.find_by_id(params[:tag]) if params.has_key?(:tag)
    @sort = params.has_key?(:s) && ['t', 'p', 'd'].include?(params[:s]) ? params[:s] : 't'
    @course_type = params.has_key?(:ct) && !CourseType.find_by_number(params[:ct].to_i).nil? ? params[:ct].to_i : nil
    if @course_type.nil?
      if params.has_key?(:course_type)
        @course_type = case params[:course_type].downcase
          when 'photography' then 1
          when 'video-production' then 2
          when 'multimedia' then 3
        end
      end
    end
    @course_type_obj = CourseType.find_by_number(@course_type) unless @course_type.nil?
    unless @course_type_obj.nil?
      @course_type_title = @course_type_obj.course_page_title
      @course_type_desc  = @course_type_obj.course_page_description
    end
    finder_options = { :include => :instructors, :page => params[:page], :order => "#{sort_fields[@sort]}", :per_page => 6 }
    if @tag.nil?
      if @course_type.nil?
        if params.has_key?(:instructor)
          @courses = User.find(params[:instructor]).courses.non_deleted.visible.available
        else
          @courses = Course.non_deleted.visible.available
        end
      else
        if params.has_key?(:instructor)
          @courses = User.find(params[:instructor]).non_deleted.visible.for_course_type(@course_type).available
          @course_list = @courses
        else
          @courses = Course.non_deleted.visible.for_course_type(@course_type).available
          @course_list = Course.non_deleted.visible.for_course_type(@course_type).available
        end
      end

      if params.has_key?(:cat) && [1, 2, 3, 4, 5].include?(params[:cat].to_i)
        case params[:cat].to_i
          when 1 then @courses = @courses.category_1
          when 2 then @courses = @courses.category_2
          when 3 then @courses = @courses.category_3
          when 4 then @courses = @courses.category_4
          when 5 then @courses = @courses.category_5
        end
      end

      # paginate() method usages apply_finder_options method which is removed from rails 4
      @courses = @courses.includes(finder_options[:include]).page(finder_options[:page]).order(finder_options[:order])
      #@courses = @courses.paginate(finder_options)
    else
      # TODO above method needs to be applied here also. since there are no tags in db so it can be changed and tested after acts_as_taggable issue is solved.

      # replace tagged_with_scope by tagged_with
      @courses = Course.non_deleted.visible.available.tagged_with(@tag.name) { Course.visible.available.non_deleted }
      @courses = @courses.paginate(finder_options.merge(:select => "DISTINCT #{Course.quoted_table_name}.*"))
    end

    @course = Course.non_deleted.visible.available.random.first
    @instructors = @course.instructors unless @course.nil?
    if params[:cat].to_i == 4
      render 'mentorship_index'
    elsif params[:cat].to_i == 3
      render 'portfolio_index'
    end
    # if @courses.map(&:category_4).uniq == [true]
    #   render 'mentorship_index' and return
    # end
  end

  def show
    @course = Course.non_deleted.available.find(params[:id])

    page_config do |page|
      page.body_tag_options[:class] = 'sales'
      page.body_tag_options[:id] = 'course'
      page.primary_navigation_section = :courses
      !@course.nil? ? @course.page_title.blank? ? page.title.unshift(@course.title) : page.title = @course.page_title : page.title.unshift("Course")
    end

    # @scheduled_courses = @course.scheduled_courses.non_deleted.enrollable(current_user).order(:starts_on)
    #@scheduled_courses = @course.scheduled_courses.non_deleted.enrollable(current_user).all(:order => :starts_on)
  rescue ActiveRecord::RecordNotFound
    flash_and_redirect_to('The requested course does not exist', :error, courses_path)
  end

  def photo
    head(:not_found) and return if (course = Course.find_by_id(params[:id])).nil?
    style = params[:style] || :original
    redirect_to(course.photo_s3_url(style))
  end

end
