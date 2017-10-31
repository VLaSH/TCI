class Instructor::MystudentsController < Instructor::BaseController  
  
  def index
    @all = params.has_key?(:all) && params[:all].to_i == 1
    if @all
      @scheduled_courses = ScheduledCourse.joins(:course).active.for_instructor(current_user).non_deleted.page(params[:page]).order('created_at ASC')
    else
      @scheduled_courses = ScheduledCourse.joins(:course).active.for_instructor(current_user).non_deleted.enrolled.page(params[:page]).order('created_at ASC')
    end
    totalcourses = []
    @scheduled_courses.each do |scheduled_course|
      totalcourses.push(scheduled_course.id)      
    end
    allcourses = totalcourses.join(",").to_s
    #abort(allcourses)
    @allenrolment = Enrolment.select("u.id, u.email, CONCAT(u.family_name,' ', u.given_name) as name, max(enrolments.end_date) end_date")
    .joins("INNER JOIN users u ON u.id = enrolments.student_user_id")
    .where("scheduled_course_id IN (#{allcourses}) AND `deleted_at` IS NULL ")
    .group("student_user_id").having("max(end_date)").order("max(end_date) DESC")    
  end
  
  def courses 
    @allcourses = Course.select("courses.*,enrolments.end_date course_end_on").joins("INNER JOIN `scheduled_courses` ON `courses`.`id` = `scheduled_courses`.`course_id`")
    .joins("INNER JOIN `enrolments` ON `scheduled_courses`.`id` = `enrolments`.`scheduled_course_id`")
    .where("`courses`.`deleted_at` IS NULL 
      AND `enrolments`.`unsubscribe` = 0 AND `enrolments`.`deleted_at` IS NULL AND `enrolments`.`student_user_id` = #{params[:id]}")
    #abort(@allcourses.to_a.to_s)
    @user = User.select("CONCAT(family_name,' ', given_name) as name")
    .find_by_id(params[:id])
  end

  protected

  def setup_page
    super
    page_config do |page|
      page.body_tag_options[:id] = 'instructor'
      page.body_tag_options[:class] = 'columns'
      page.secondary_navigation_section = :mystudents
      page.secondary_navigation = true
      page.title.unshift('My Students')
    end
  end

  
end
