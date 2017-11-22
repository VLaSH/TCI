class Administrator::CritiquesController < Administrator::BaseController

  include Theia::ActsAsCritiqueable::Controller

  def new
    @critique = build_critique
  end

  def create
    @critique = build_critique(params[:critique])

    if @critique.save
      flash_and_redirect_to('Your critique has been created successfully', :notice, polymorphic_path([ :administrator, @critique.critiqueable ]))
    else
      render(:action => 'new')
    end
  end

  def edit
  end

  def update
    if @critique.update_attributes(params[:critique])
      flash_and_redirect_to('Your critique has been updated successfully', :notice, polymorphic_path([ :administrator, @critique.critiqueable ]))
    else
      render(:action => 'edit')
    end
  end

  def delete
  end

  def destroy
    if @critique.delete!
      flash_and_redirect_to('Your critique has been deleted successfully', :notice, polymorphic_path([ :administrator, @critique.critiqueable ]))
    else
      render(:action => 'delete')
    end
  end

end