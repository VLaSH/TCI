class Instructor::LessonsController < Instructor::BaseController

  include Theia::ActsAsDiscussable::Controller

  def show
    @lesson = Lesson.find_by_id(params[:id])
    #@lesson = @scheduled_lesson.lesson
    @course = @lesson.course

    if (@lesson.nil?)
      flash_and_redirect_to('The lesson you requested does not exist', :error, user_role_root_path)
    end

    @forum_topics = ForumTopic.where(discussable_id: @lesson.scheduled_lessons.pluck(:id), discussable_type: 'ScheduledLesson')
    @forum_topic = @forum_topics.first
    unless @forum_topic.nil?
      @forum_post = build_forum_post
    end
  end

  protected

  def setup_page
    super
    page_config do |page|
      page.body_tag_options[:id] = 'instructor'
      page.body_tag_options[:class] = 'columns'
      page.secondary_navigation_section = :courses
      page.secondary_navigation = true
      page.title.unshift('Lesson')
    end
  end
end
