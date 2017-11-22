class Administrator::RearrangementsController < Administrator::BaseController

  before_filter :find_assignment, :only => [ :index, :new, :create ]
  before_filter :find_rearrangement, :except => [ :index, :new, :create ]

  def index
    # add non_deleted methods because after deleted see all images and this methods filter non_deleted images
    #@rearrangements = @assignment.rearrangements.paginate(:page => params[:page])
    @rearrangements = @assignment.rearrangements.non_deleted.paginate(:page => params[:page])
  end

  def show
  end

  def new
    @rearrangement = @assignment.rearrangements.build
  end

  def create
    @rearrangement = @assignment.rearrangements.build(params[:rearrangement])

    if @rearrangement.save
      flash_and_redirect_to('You have successfully created a new rearrangement', :notice, administrator_assignment_rearrangements_path(@assignment))
    else
      render(:action => 'new')
    end
  end

  def edit
  end

  def update
    if @rearrangement.update_attributes(params[:rearrangement])
      flash_and_redirect_to('The rearrangement has been updated successfully', :notice, administrator_assignment_rearrangements_path(@rearrangement.assignment))
    else
      render(:action => 'edit')
    end
  end

  def delete

  end

  def destroy
    if @rearrangement.delete!
      flash_and_redirect_to('Your rearrangement has been deleted successfully', :notice, administrator_assignment_rearrangements_path(@rearrangement.assignment_id))
    else
      render(:action => 'delete')
    end
  end

  protected

    def find_assignment
      @assignment = Assignment.non_deleted.find(params[:assignment_id])
    rescue ActiveRecord::RecordNotFound
      flash_and_redirect_to('The requested assignment does not exist', :error, administrator_root_path)
    end

    def find_rearrangement
      @rearrangement = Rearrangement.non_deleted.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash_and_redirect_to('The requested rearrangement does not exist', :error, administrator_assignment_rearrangements_path(@assignment))
    end

end