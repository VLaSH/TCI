class Instructor::UpdatesController < Instructor::BaseController

  
  
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
    @allenrolment = Enrolment.where("scheduled_course_id IN (#{allcourses}) AND `deleted_at` IS NULL ").group("student_user_id")
    #abort(@allenrolment.to_a.size.to_s)
    totalenrolments = []
    @allenrolment.each do |allenrolment|
      totalenrolments.push(allenrolment.id)      
    end
    allenrolments = totalenrolments.join(",").to_s
    
    @submissions = AssignmentSubmission.select("assignment_submissions.id, assignment_submissions.title, CONCAT(u.family_name,' ', u.given_name) as name")
    .joins("LEFT JOIN enrolments e ON e.id = assignment_submissions.enrolment_id")
    .joins("LEFT JOIN users u ON u.id = e.student_user_id").where("enrolment_id IN (#{allenrolments}) AND completed = 1 AND instructor_unread = 1")
    .order("assignment_submissions.updated_at DESC")
    
    #abort(@submissions.to_a.size.to_s)
    
    #@assignment = Assignment.all
  end

  protected

  def setup_page
    super
    page_config do |page|
      page.body_tag_options[:id] = 'instructor'
      page.body_tag_options[:class] = 'columns'
      page.secondary_navigation_section = :updates
      page.secondary_navigation = true
      page.title.unshift('Updates')
    end
  end

  
end
