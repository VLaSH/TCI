class BlogsController < ApplicationController
 include Theia::ActsAsDiscussable::Controller
  
  def index
    @search = params.has_key?(:search) && !params[:search].blank? ? params[:search] : nil
    @conditions = "(blogs.hidden=0)"
    unless @search.nil?
      @conditions = "(blogs.title like '%#{@search}%')"
    end

    @blogs = Blog.page(params[:page]).order('id DESC').where(@conditions)
  end

  def show
   @blog = Blog.find(params[:id])   
   @Blogcomment = Blogcomment.where(blog_id: @blog.id).select('user_id,given_name,role,comment,blogcomments.created_at').joins("LEFT JOIN users ON users.id = blogcomments.user_id")    
      render layout: "blog"  
	
    
      rescue ActiveRecord::RecordNotFound
        flash_and_redirect_to('The requested blog does not exist', :error, administrator_blogs_path)
  end
 def savecomment
	p = params[:comment]
	p[:user_id] = current_user.id
	@Blogcomment = Blogcomment.new(p)
    if @Blogcomment.save
	 render :json => 1	
	else
		render :json => 0
	end
	end
	
  def new
    @blog = Blog.new
  end
def certificate
	
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
    if @blog.delete!
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
      params.require(:blog).permit(:title,  :page_title, :meta_description, :meta_keywords, :available, :hidden, :content, :photo, :delete_photo)

    end

end
