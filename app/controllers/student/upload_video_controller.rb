class Student::UploadVideoController < Student::BaseController

#  include Theia::ActsAsDiscussable::Controller
  before_filter :find_attachable, :attachable_setup_page, :only => [ :index, :new, :create, :order, :change_image_order ]
  before_filter :find_attachment, :attachment_setup_page, :only => [ :show, :edit, :update, :delete, :destroy ]

  def order
    params[:attachment_thumbnails].each_with_index do |id, index|
      Attachment.update_all(['position = ?', index + 1], ['id = ?', id])
    end
    render :nothing => true
  end

  def new
    @attachment = build_attachment
    @current_user =18
    @lesson_ids =@attachment.attachable_id 
    @assign_id = params[:assignments_id]
  end

  def create
     @current_user =18
     @attachment = Attachment.new(params[:attachment])
     @lesson_ids =@attachment.attachable_id 
     @assign_id = params[:assignments_id]
     if @attachment.save
        redirect_to "/student/assignments/#{params[:assignments_id]}"
    else
      respond_to do |format|
        format.html { render(:action => 'new') }
        format.js { render :text => message }
        format.json { render :json => { :success => false, :message => message } }
      end  
    end  
  end

  def edit
    @attachable = @attachment.attachable
  end

  def update
    if @attachment.update_attributes(params[:attachment])
      flash_and_redirect_to('Your attachment has been updated successfully', :notice, polymorphic_attachments_path(@attachment.attachable))
    else
      render(:action => 'edit')
    end
  end

  def delete
    logger.debug('here')
    logger.debug(@attachment.to_yaml) if !@attachment.nil?
  end

  def destroy
    if @attachment.delete!
      flash_and_redirect_to('Your attachment has been deleted successfully', :notice, polymorphic_attachments_path(@attachment.attachable))
    else
      render(:action => 'delete')
    end
  end
  # Action for change current image order and update position of images
  def change_image_order
    params[:attachment_thumbnails].split(',').each_with_index do |id, index|
      Attachment.update_all(['position = ?', index + 1], ['id = ?', id])
    end
    respond_to do |format|
      format.js
    end
  end
protected

  def get_upload_text(attachment)
    raise 'implement get_upload_text in your controller'
  end

  def basic_uploads_json(attachment)
    attachment.to_json(:only => [:id, :file_name])
  end

  def attachable_setup_page
    page_config do |page|
      page.secondary_navigation_section = @attachable.class.name.pluralize.downcase.to_sym
      page.title.unshift("Attachments")
    end
  end

  def attachment_setup_page
    page_config do |page|
      page.secondary_navigation_section = @attachment.attachable.class.name.pluralize.downcase.to_sym
      page.title.unshift("Attachments")
    end
  end

end
