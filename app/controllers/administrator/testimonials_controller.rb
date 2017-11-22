class Administrator::TestimonialsController < Administrator::BaseController
  before_filter :set_testimonial, :except => [ :index, :new, :create ]
  # GET /administrator/testimonials
  # GET /administrator/testimonials.json
  def index
    @testimonials = Testimonial.all
    @setting = Settings.find_by(key: 'video_url')
  end

  # GET /administrator/testimonials/1
  # GET /administrator/testimonials/1.json
  def show
  end

  # GET /administrator/testimonials/new
  def new
    @testimonial = Testimonial.new
  end

  # GET /administrator/testimonials/1/edit
  def edit
  end

  # POST /administrator/testimonials
  # POST /administrator/testimonials.json
  def create
    @testimonial = Testimonial.new(testimonial_params)

      if @testimonial.save
        flash_and_redirect_to('You have successfully created a new testimonial', :notice, administrator_testimonials_path)
      else
        render(:action => 'new')
      end
  end

  # PATCH/PUT /administrator/testimonials/1
  # PATCH/PUT /administrator/testimonials/1.json
  def update
     if @testimonial.update_attributes(testimonial_params)
      flash_and_redirect_to('You have successfully updated the testimonial', :notice, administrator_testimonials_path)
    else
      render(:action => 'edit')
    end
  end


  def delete
  end

  # DELETE /administrator/testimonials/1
  # DELETE /administrator/testimonials/1.json
  def destroy
    if @testimonial.delete
      flash_and_redirect_to('The testimonial has been deleted successfully', :notice, administrator_testimonials_url)
    else
      render(:action => 'delete')
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_testimonial
      @testimonial = Testimonial.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def testimonial_params
      params.require(:testimonial).permit(:title, :content, :logo)
    end

    # setup the page for testimonials
    def setup_page
      page_config do |page|
        super
        page.secondary_navigation_section = :testimonials
        page.title.unshift('Testimonials')
      end
    end
end
