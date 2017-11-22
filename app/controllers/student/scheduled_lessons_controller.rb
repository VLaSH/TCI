class Student::ScheduledLessonsController < Student::BaseController

  include Theia::ActsAsDiscussable::Controller

  def show
  #puts params[:id]
	#puts 'pardeep'
    @scheduled_lesson = ScheduledLesson.find(params[:id])
   @forum_topics = ForumTopic.where(discussable_id: @scheduled_lesson.lesson.scheduled_lessons.pluck(:id), discussable_type: 'ScheduledLesson')
    @forum_topic = @forum_topics.first
    
    @allenrolment = Enrolment.select("u.id, u.email, CONCAT(u.given_name,' ', u.family_name) as name, max(enrolments.end_date) end_date,case when  end_date > now() then 1 else 0 end as enrol")
    .joins("INNER JOIN users u ON u.id = enrolments.student_user_id")
    .where("scheduled_course_id =#{params[:course_id]} AND `deleted_at` IS NULL ")
    .group("student_user_id").having("max(end_date)").order("max(end_date) DESC") 
     #puts @allenrolment
    unless @forum_topics.nil?
      @forum_post = build_forum_post
	
    end
    @lesson = @scheduled_lesson.lesson
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "show"
      end
    end
  end


protected
  def setup_page
    super
    page_config do |page|
      page.body_tag_options[:class] = 'student'
      page.body_tag_options[:id] = 'lessons'
      page.secondary_navigation_section = :courses
      page.secondary_navigation = true
      page.title.unshift('Lesson')
    end
  end
end
