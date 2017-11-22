class Instructor::AttachmentsController < Instructor::BaseController

  before_filter :find_attachable, :only => [ :new, :create ]
  before_filter :find_attachment, :only => [ :show, :edit, :update, :delete, :destroy ]

  def order
    @assignment_submission = AssignmentSubmission.find(params[:submission_id])
    @assignment_submission.rearrangement = params[:attachment_thumbnails]
    @assignment_submission.save!
  end

  def index
    @attachments = AssignmentSubmission.find(params[:submission_id])
  end

  def show
  end

  def new
    @attachment = build_attachment
  end

  def create
    @attachment = build_attachment(params[:attachment])

    if @attachment.save
      flash_and_redirect_to('Your attachment has been created successfully', :notice, polymorphic_attachments_path(@attachment.attachable))
    else
      render(:action => 'new')
    end
  end

  def edit
  end

  def update
    if @attachment.update_attributes(params[:attachment])
      submission = AssignmentSubmission.find(params[:submission_id])
      flash_and_redirect_to('Your attachment has been updated successfully', :notice, instructor_submission_path(submission))
    else
      render(:action => 'edit')
    end
  end

  def delete
  end

  def destroy
    if @attachment.delete
      submission = AssignmentSubmission.find(params[:submission_id])
      flash_and_redirect_to('Your attachment has been deleted successfully', :notice, instructor_submission_path(submission))
    else
      render(:action => 'delete')
    end
  end
end
