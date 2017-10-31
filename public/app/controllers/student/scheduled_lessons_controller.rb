class Student::ScheduledLessonsController < Student::BaseController

  include Theia::ActsAsDiscussable::Controller

  def show
    @scheduled_lesson = ScheduledLesson.find(params[:id])
    @forum_topics = ForumTopic.where(discussable_id: @scheduled_lesson.lesson.scheduled_lessons.pluck(:id), discussable_type: 'ScheduledLesson')
    @forum_topic = @forum_topics.first
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
