class Instructor::AssignmentSubmissionsController < Instructor::BaseController

  before_filter :find_scheduled_assignment, :only => :index
  before_filter :find_assignment_submission, :except => :index

  def index
    @assignment_submissions = @scheduled_assignment.submissions.paginate(:page => params[:page], :order => :updated_at)
  end

  def show
  end

  def edit
  end

  def update
    if @assignment_submission.update_attributes(params[:assignment_submission])
      flash_and_redirect_to('The submission has been updated successfully', :notice, instructor_courses_path)
    else
      render(:action => 'edit')
    end
  end

  def delete
  end

  def destroy
    if @assignment_submission.delete!
      flash_and_redirect_to('The submission has been deleted successfully', :notice, instructor_courses_path)
    else
      render(:action => 'delete')
    end
  end

  protected

    def find_scheduled_assignment
      @scheduled_assignment = ScheduledAssignment.non_deleted.find(params[:scheduled_assignment_id])
    rescue ActiveRecord::RecordNotFound
      flash_and_redirect_to('The requested scheduled assignment does not exist', :error, instructor_root_path)
    end

    def find_assignment_submission
      @assignment_submission = AssignmentSubmission.non_deleted.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash_and_redirect_to('The requested assignment submission does not exist', :error, instructor_courses_path)
    end
    
    def setup_page
      super
      page_config do |page|
        page.body_tag_options[:class] = 'instructor'
        page.body_tag_options[:id] = 'assignmentsubmissions'
        page.secondary_navigation_section = :courses
        page.secondary_navigation = true
        page.title.unshift('Assignment Submissions')
      end
    end

end