class Administrator::PackagesController < Administrator::BaseController

  before_filter :find_package, :except => [ :index, :new, :create ]
  helper :packages

  def index
    @search = params.has_key?(:search) && !params[:search].blank? ? params[:search] : nil
    @conditions = ""
    unless @search.nil?
      @conditions = "(packages.title like '%#{@search}%')"
    end
    
    @packages = Package.non_deleted.paginate(:page => params[:page], :order => 'title ASC', :conditions => @conditions)
  end

  def show
  end

  def new
    @package = Package.new
  end

  def create
    @package = Package.new(params[:package])

    if @package.save
      flash_and_redirect_to('You have successfully created a new package', :notice, administrator_packages_path)
    else
      render(:action => 'new')
    end
  end

  def edit
  end

  def update
    if @package.update_attributes(params[:package])
      flash_and_redirect_to('You have successfully updated the package', :notice, administrator_packages_path)
    else
      render(:action => 'edit')
    end
  end

  def delete
  end

  def destroy
    if @package.delete!
      flash_and_redirect_to('Your package has been deleted successfully', :notice, administrator_packages_path)
    else
      render(:action => 'delete')
    end
  end

  protected

    def find_package
      @package = Package.non_deleted.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash_and_redirect_to('The requested package does not exist', :error, administrator_packages_path)
    end
    
    def setup_page
      page_config do |page|
        super
        page.secondary_navigation_section = :packages
        page.title.unshift('Packages')
      end
    end

end