class Administrator::BannerImagesController < Administrator::BaseController
  before_filter :find_image, :only => :destroy
  def index
    @home            = HomeBanner.all
    @how_it_work     = HowItWorkBanner.all
    @mentorship      = MentorshipBanner.all
    @workshop        = WorkshopBanner.all
    @photography     = CoursePhotographyBanner.all
    @multimedia      = CourseMultimediaBanner.all
    @portfolio       = PortfolioBanner.all
    @course_grid     = CourseGridSection.all
    @portfolio_grid  = PortfolioGridSection.all
    @mentorship_grid = MentorshipGridSection.all
    @gallery_grid    = StudentGalleryGridSection.all
    @whats_new_grid  = WhatsNewGridSection.all
    @tci_blog_grid   = TciBlogGridSection.all
    @banner_image    = BannerImage.new
  end

  def create
    @image = BannerImage.new( image_params )
    if @image.save
      flash_and_redirect_to('Image Created Sucessfully', :notice, administrator_banner_images_path)
    else
      flash_and_redirect_to("image #{@image.errors.messages[:image].first}" , :alert, administrator_banner_images_path)
    end
  end

  def destroy
    if @image.destroy
      flash_and_redirect_to('Image Deleted Sucessfully', :notice, administrator_banner_images_path)
    else
      flash_and_redirect_to('Image not deleted', :error, administrator_banner_images_path)
    end
  end

  def setup_page
      page_config do |page|
        super
        page.secondary_navigation_section = :banner_images
        page.title.unshift('Banner Images')
      end
    end

  def find_image
    @image = BannerImage.find(params[:id])
  end

  private

  def image_params
    params.require(:banner_image).permit(:type, :image)
  end
end
