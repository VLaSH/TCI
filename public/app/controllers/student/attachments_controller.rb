class Student::AttachmentsController < Student::BaseController

  before_filter :find_attachable, :only => [ :index, :new, :create, :order, :sequence ]
  before_filter :find_attachment, :only => [ :show, :edit, :update, :delete, :destroy ]

  def sequence
    @attachments = @attachable.attachments
  end

  # Set Position of images after rearrangement images.
  def order
    params[:attachment_thumbnails].split(',').each_with_index do |id, index|
      Attachment.update_all(['position = ?', index + 1], ['id = ?', id])
    end
  end

  def index
    #@attachments = @attachable.attachments.paginate(:page => params[:page], :order => :position)
    @attachments = current_user.owned_attachments(:order => :position)
  end

  def show
  end

  def new
    @redirect = (params.has_key?(:redirect) ? params[:redirect] : nil)
    @attachment = build_attachment
  end

  def create
     @redirect = (params[:attachment].has_key?(:redirect) ? params[:attachment][:redirect] : nil) if params.has_key?(:attachment)
  #   @attachment = build_attachment(params[:attachment])
  #   @attachment.save!

  #   respond_to do |format|
  #     format.html { flash_and_redirect_to('Your attachment has been created successfully', :notice, polymorphic_attachments_path(@attachment.attachable)) }
  #     format.js { render :text => get_upload_text(@attachment) }
  #     format.json { render :json => basic_uploads_json(@attachment) }
  #   end
  # rescue Exception => e
  #   @attachment = build_attachment(params[:attachment])
  #   message = 'You must enter a title and attach a file'
  #   flash.now[:error] = message
  #   respond_to do |format|
  #     format.html { render(:action => 'new') }
  #     format.js { render :text => message }
  #     format.json { render :json => { :success => false, :message => message } }
  #   end
    @attachment = build_attachment(params[:attachment])

    if @attachment.save
      respond_to do |format|
        format.html { flash_and_redirect_to('Your attachment has been created successfully', :notice, @redirect.nil? ? polymorphic_attachments_path(@attachment.attachable) : @redirect) }
        format.js { render :text => get_upload_text(@attachment) }
        format.json { render :json => basic_uploads_json(@attachment) }
      end
    else
      respond_to do |format|
        format.html { render(:action => 'new') }
        format.js { render :text => message }
        format.json { render :json => { :success => false, :message => message } }
      end
    end
  end

  def edit
    @redirect = (params.has_key?(:redirect) ? params[:redirect] : nil)
    @attachable = @attachment.attachable
  end

  def update
    @redirect = (params[:attachment].has_key?(:redirect) ? params[:attachment][:redirect] : nil) if params.has_key?(:attachment)
    if @attachment.update_attributes(params[:attachment])
      flash_and_redirect_to('Your attachment has been updated successfully', :notice, @redirect.nil? ? polymorphic_attachments_path(@attachment.attachable) : @redirect)
    else
      render(:action => 'edit')
    end
  end

  def delete
    @redirect = (params.has_key?(:redirect) ? params[:redirect] : nil)
  end

  def destroy
    @redirect = (params[:attachment].has_key?(:redirect) ? params[:attachment][:redirect] : nil) if params.has_key?(:attachment)
    if @attachment.delete!
      flash_and_redirect_to('Your attachment has been deleted successfully', :notice, @redirect.nil? ? polymorphic_attachments_path(@attachment.attachable) : @redirect)
    else
      render(:action => 'delete')
    end
  end

  protected
    def setup_page
      super
      page_config do |page|
        page.body_tag_options[:class] = 'student'
        page.body_tag_options[:id] = 'attachments'
        page.secondary_navigation_section = :attachments
        page.secondary_navigation = true
        page.title.unshift('Photos')
      end
    end

end
