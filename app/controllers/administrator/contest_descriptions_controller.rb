class Administrator::ContestDescriptionsController < Administrator::BaseController
  def new
  	@contest_description = ContestDescription.new
  end

  def index
  	@cd = ContestDescription.find(:last)
  end

  def create
  	@contest_description = ContestDescription.new(description_params)
    
    #if @contest_description.save
    #  redirect_to :action => 'index'  
    #end
    if @contest_description.save
        flash_and_redirect_to('You have successfully added content', :notice, administrator_contest_descriptions_path)
      else
        render(:action => 'new')
      end

  end

  def description_params
      params.require(:contest_description).permit(:content)
  end
   
end
