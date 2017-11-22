class Student::ScheduledAssignmentsController < Student::BaseController

  include Theia::ActsAsDiscussable::Controller
  before_filter :find_scheduled_assignment, :except => [:index]

  def index
    @enrolment_date = Enrolment.user_enrolments(current_user).last
  end

  # This methods use for show assignment details and generate pdf of assignment details
  def show
    @check_login =user_role_root_path
    @forum_topics = ForumTopic.where(discussable_id: @scheduled_assignment.assignment.scheduled_assignments.pluck(:id), discussable_type: 'ScheduledAssignment')
    @forum_topic = @forum_topics.first
    @assing_id = @scheduled_assignment.assignment_id
    @lession_id = params[:id]
    unless @forum_topic.blank?
      @forum_post = build_forum_post
    end
    @submissions = @scheduled_assignment.submissions.by_student(current_user)
    if @scheduled_assignment && @scheduled_assignment.scheduled_lesson.enrolment.end_date >= Date.today
      @other_submissions = AssignmentSubmission.where(scheduled_assignment_id: @scheduled_assignment.assignment.scheduled_assignments.pluck(:id)).not_by_student(current_user).current_enrolments
    else
      @other_submissions = AssignmentSubmission.where(scheduled_assignment_id: @scheduled_assignment.assignment.scheduled_assignments.pluck(:id)).by_student(current_user)
    end
    respond_to do |format|
      format.html
      format.pdf do
        render :pdf => "show"
      end
    end
  end

  # generate pdf for assingmnet detail
  def generate_pdf
    respond_to do |format|
      format.html
      format.pdf do
        render :pdf => "generate_pdf"
      end
    end
  end

protected
  def setup_page
    super
    page_config do |page|
      page.body_tag_options[:class] = 'student'
      page.body_tag_options[:id] = 'scheduledassignments'
      page.secondary_navigation_section = :assignments
      page.secondary_navigation = true
      page.title.unshift('Assignments')
    end
  end

  def find_scheduled_assignment
    if (@scheduled_assignment = ScheduledAssignment.find_by_id(params[:id])).nil? || (@assignment = @scheduled_assignment.assignment).nil?
      flash_and_redirect_to('The requested assignment does not exist', :error, user_role_root_path)
    end
  end
end
