class Administrator::GiftsController < Administrator::BaseController
  before_action :gift, only: [:edit, :update, :destroy]

  def index
    @search = params.has_key?(:search) && !params[:search].blank? ? params[:search] : nil
    @conditions = ""
    unless @search.nil?
      @conditions = "(gifts.title like '%#{@search}%')"
    end

    @gifts = Gift.page(params[:page]).order('title ASC').where(@conditions)
  end

  def new
    @gift = Gift.new
  end

  def create
    @gift = Gift.new(gift_params)

    if @gift.valid? && @gift.save
      flash_and_redirect_to('You have successfully created a new gift', :notice, administrator_gifts_path)
    else
      render :new
    end
  end

  def update
    if @gift.update(gift_params)
      flash_and_redirect_to('You have successfully updated a gift', :notice, administrator_gifts_path)
    else
      render :edit
    end
  end

  def destroy
    @gift.destroy
    flash_and_redirect_to('You have successfully deleted a gift', :notice, administrator_gifts_path)
  end

  private

  def gift_params
    params.require(:gift).permit(:title, :lessons_amount, :price, :description, :category, :course_id)
  end

  def gift
    @gift ||= Gift.find_by(id: params[:id])
  end

  protected

  def setup_page
    page_config do |page|
      super
      page.secondary_navigation_section = :gifts
      page.title.unshift('Gifts')
    end
  end
end
