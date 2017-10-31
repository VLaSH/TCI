class Administrator::StudentGalleriesController < Administrator::BaseController

  before_filter :find_gallery_image, :only => :destroy

  def index
    @images = StudentGallery.all
    @students = User.where(role: 's')
    @student_gallery = StudentGallery.new
  end

  def create
    @student_gallery = StudentGallery.new( gallery_image_params )
    if @student_gallery.save
      flash_and_redirect_to('Student Gallery Created Sucessfully', :notice, administrator_student_galleries_path)
    else
      flash_and_redirect_to("gallery image not created " , :alert, administrator_student_galleries_path)
    end
  end

  def edit
  end

  def destroy
    if @gallery_image.destroy
      flash_and_redirect_to('Your workshop has been deleted successfully', :notice, administrator_student_galleries_path)
    else
      flash_and_redirect_to('Gallery Image not deleted', :error, administrator_student_galleries_path)
    end
  end

  protected

    def find_gallery_image
      @gallery_image = StudentGallery.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash_and_redirect_to('The requested gallery image does not exist', :error, administrator_student_galleries_path)
    end

    def setup_page
      page_config do |page|
        super
        page.secondary_navigation_section = :student_gallries
        page.title.unshift('Gallery')
      end
    end

   private

    def gallery_image_params
       params.require(:student_gallery).permit(:creator, :course,:image)
    end

end
