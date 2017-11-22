class Administrator::PartnersController < Administrator::BaseController

  before_filter :find_partner, :except => [ :index, :new, :create ]

  def index
    @partners = Partner.paginate(:page => params[:page], :order => 'name ASC')
  end

  def show
  end

  def new
    @partner = Partner.new
  end

  def create
    @partner = Partner.new(params[:partner])
    
    if @partner.save
      flash_and_redirect_to('You have successfully created a new partner', :notice, administrator_partners_path)
    else
      render(:action => 'new')
    end
  end

  def edit
  end

  def update
    if @partner.update_attributes(params[:partner])
      flash_and_redirect_to('You have successfully updated the partner', :notice, administrator_partners_path)
    else
      render(:action => 'edit')
    end
  end
  
  def delete
  end

  def destroy
    if @partner.delete
      flash_and_redirect_to('The partner has been deleted successfully', :notice, administrator_partners_path)
    else
      render(:action => 'delete')
    end
  end

  protected

    def find_partner
      @partner = Partner.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash_and_redirect_to('The requested partner does not exist', :error, administrator_partners_path)
    end
    
    def setup_page
      page_config do |page|
        super
        page.secondary_navigation_section = :partners
        page.title.unshift('Partners')
      end
    end

end