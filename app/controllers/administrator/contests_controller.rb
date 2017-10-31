class Administrator::ContestsController < Administrator::BaseController

  #before_filter :find_course, except: [ :index, :new, :create ]
  #helper :courses

  # def index
  #   @search = params.has_key?(:search) && !params[:search].blank? ? params[:search] : nil
  #   @conditions = ""
  #   unless @search.nil?
  #     @conditions = "(courses.title like '%#{@search}%')"
  #   end

  #   @courses = Course.non_deleted.page(params[:page]).order('title ASC').where(@conditions)
  # end

  def new
    @contest = Contest.new
  end

  def create
    @contest = Contest.new(params[:contest])
    
    if @contest.save
      redirect_to :action => 'index'  
    end    
  end
end
