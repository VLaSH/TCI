class Student::AssignmentSubmissionsController < Student::BaseController

  before_filter :find_assignment_submission, :except => [ :index, :new, :create ]
  before_filter :find_scheduled_assignment, :except => [ :sequence ]
  before_filter :find_scheduled_course, :only => [:new, :create]
  before_filter :find_enrolment, :only => [:new, :create]

  def sequence
    @assignment_submission.rearrangement = params[:sequence]
    @assignment_submission.save!
    redirect_to student_submission_path(@assignment_submission)
  end

  def new
    @assignment_submission = AssignmentSubmission.new
    @assignment_submission.scheduled_assignment = @scheduled_assignment
    @redirect = params[:redirect] if params.has_key?(:redirect)
  end

  def create
    @assignment_submission = AssignmentSubmission.new(params[:assignment_submission])
    @assignment_submission.scheduled_assignment = @scheduled_assignment
    @assignment_submission.enrolment = @enrolment

    if @assignment_submission.save
      flash_and_redirect_to('You have successfully created your assignment submission', :notice, student_submission_path(@assignment_submission))
    else
      render(:action => 'new')
    end
  end

  def show
  end

  def edit
  end

  def update
    if @assignment_submission.update_attributes(params[:assignment_submission])
      flash_and_redirect_to('The submission has been updated successfully', :notice, student_submission_path(@assignment_submission))
    else
      render(:action => 'edit')
    end
  end

  def delete
  end

  def destroy
    if @assignment_submission.delete!
      flash_and_redirect_to('The submission has been deleted successfully', :notice, student_submissions_path)
    else
      render(:action => 'delete')
    end
  end

  protected
    def setup_page
      super
      page_config do |page|
        page.body_tag_options[:class] = 'student'
        page.body_tag_options[:id] = 'assignmentsubmission'
        page.secondary_navigation_section = :assignments
        page.secondary_navigation = true
        page.title.unshift('Assignments')
      end
    end

    def find_assignment_submission
      logger.debug params.to_yaml
      @assignment_submission = AssignmentSubmission.non_deleted.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash_and_redirect_to('The requested assignment submission does not exist', :error, student_assignments_path)
    end

    def find_scheduled_assignment
      if @assignment_submission.nil?
        @scheduled_assignment = ScheduledAssignment.non_deleted.find(params[:assignment_id])
      else
        @scheduled_assignment = @assignment_submission.scheduled_assignment
      end
    rescue ActiveRecord::RecordNotFound
      flash_and_redirect_to('The requested assignment does not exist', :error, student_assignments_path)
    end

    def find_scheduled_course
      @scheduled_course = @scheduled_assignment.scheduled_lesson.scheduled_course
    rescue ActiveRecord::RecordNotFound
      flash_and_redirect_to('The requested course does not exist', :error, student_assignments_path)
    end

    def find_enrolment
      # @enrolment = Enrolment.find_by_student_user_id_and_scheduled_course_id(current_user, @scheduled_course)
      @enrolment = ScheduledAssignment.find(params[:assignment_id]).scheduled_lesson.enrolment
    rescue ActiveRecord::RecordNotFound
      flash_and_redirect_to('The requested enrollment does not exist', :error, student_assignments_path)
    end
end
