class Administrator::BlogsController < Administrator::BaseController

  before_filter :find_blog, except: [ :index, :new, :create ]
  helper :blogs

  def index
    @search = params.has_key?(:search) && !params[:search].blank? ? params[:search] : nil
    @conditions = ""
    unless @search.nil?
      @conditions = "(blogs.title like '%#{@search}%')"
    end

    @blogs = Blog.page(params[:page]).order('title ASC').where(@conditions)
  end

  def show
  end

  def new
    @blog = Blog.new
  end

  def create
    @blog = Blog.new(permit_params.except(:instructor_ids))

    if @blog.save    
      flash_and_redirect_to('You have successfully created a new blog', :notice, administrator_blogs_path)
    else
      render action: :new
    end
  end

  def edit
  end

  def update  
    if @blog.update_attributes(permit_params)
      flash_and_redirect_to('You have successfully updated the blog', :notice, administrator_blogs_path)
    else    
      render action: :edit
    end
  end

  def delete
  end

  def destroy
    if @blog.delete
      flash_and_redirect_to('Your blog has been deleted successfully', :notice, administrator_blogs_path)
    else
      render action: :delete
    end
  end

  protected

    def find_blog
      @blog = Blog.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash_and_redirect_to('The requested blog does not exist', :error, administrator_blogs_path)
    end

    def setup_page
      page_config do |page|
        super
        page.secondary_navigation_section = :blogs
        page.title.unshift('Blogs')
      end
    end

    def permit_params
      params.require(:blog).permit(:title, :banner_photo, :page_title, :hidden, :meta_description, :meta_keywords, :content, :photo, :delete_photo, :vimeo_video_id)

    end

end
