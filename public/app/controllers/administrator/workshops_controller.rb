class Administrator::WorkshopsController < Administrator::BaseController

  before_filter :find_workshop, :except => [ :index, :new, :create ]

  def index
    @search = params.has_key?(:search) && !params[:search].blank? ? params[:search] : nil
    @conditions = ""
    unless @search.nil?
      @conditions = "(workshops.title like '%#{@search}%')"
    end
    
    @workshops = Workshop.non_deleted.paginate(:page => params[:page], :order => 'title ASC', :conditions => @conditions)
  end

  def show
  end

  def new
    @workshop = Workshop.new
  end

  def create
    @workshop = Workshop.new(params[:workshop])

    if @workshop.save
      flash_and_redirect_to('You have successfully created a new workshop', :notice, administrator_workshops_path)
    else
      render(:action => 'new')
    end
  end

  def edit
  end

  def update
    if @workshop.update_attributes(params[:workshop])
      flash_and_redirect_to('You have successfully updated the workshop', :notice, administrator_workshops_path)
    else
      render(:action => 'edit')
    end
  end

  def delete
  end

  def destroy
    if @workshop.delete!
      flash_and_redirect_to('Your workshop has been deleted successfully', :notice, administrator_workshops_path)
    else
      render(:action => 'delete')
    end
  end

  protected

    def find_workshop
      @workshop = Workshop.non_deleted.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash_and_redirect_to('The requested workshop does not exist', :error, administrator_workshops_path)
    end
    
    def setup_page
      page_config do |page|
        super
        page.secondary_navigation_section = :workshops
        page.title.unshift('Workshops')
      end
    end

end