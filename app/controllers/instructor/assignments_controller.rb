class Instructor::AssignmentsController < Instructor::BaseController

  include Theia::ActsAsDiscussable::Controller
  before_filter :find_assignment

  def show
    @check_login =user_role_root_path
    @assg_id =@assignment.id
    @submissions = AssignmentSubmission.where(scheduled_assignment_id: @assignment.scheduled_assignments)
    @course = @assignment.lesson.course
    @scheduled_assignment = @assignment.scheduled_assignments.last
    @forum_topics = ForumTopic.where(discussable_id: @assignment.scheduled_assignments.pluck(:id), discussable_type: 'ScheduledAssignment')
    @forum_topic = @forum_topics.first
    unless @forum_topic.blank?
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
      page.title.unshift('Assignment')
    end
  end

  def find_assignment
    if (@assignment = Assignment.find_by_id(params[:id])).nil?
      flash_and_redirect_to('The requested assignment does not exist', :error, user_role_root_path)
    end
  end
end
