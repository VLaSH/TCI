class Administrator::RenewalsController < Administrator::BaseController
  before_filter :find_course, :only => [:index, :create, :destroy]
  before_filter :find_renewal, :only=> [:destroy]

  def index

  end

  def create
    @renewal = @course.renewals.build(params[:renewal])
    if @renewal.save
      flash_and_redirect_to('Renewal created successfully ', :notice, administrator_renewals_path(course_id: @course))
    else
      flash_and_redirect_to('Failed to add renewal', :error,administrator_renewals_path(course_id: @course))
    end
  end

  def destroy
    if @renewal.update_attribute(:deleted_at, Time.now)
      flash_and_redirect_to('The renewal has been deleted successfully', :notice, administrator_renewals_path(course_id: @renewal.course.id))
    else
      render(:action => 'index')
    end
  end

  protected

    def find_course
      @course = Course.non_deleted.find(params[:course_id])
    end

    def find_renewal
      @renewal = @course.renewals.find(params[:id])
    end

end
