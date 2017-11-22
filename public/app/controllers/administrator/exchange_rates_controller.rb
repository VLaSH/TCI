class Administrator::ExchangeRatesController < Administrator::BaseController

  before_filter :find_exchange_rate, :only => [ :edit, :update, :delete, :destroy ]

  def index
    @exchange_rates = ExchangeRate.paginate(:page => params[:page], :order => 'base_currency ASC, counter_currency ASC')
  end

  def new
    @exchange_rate = ExchangeRate.new
  end

  def create
    @exchange_rate = ExchangeRate.new(params[:exchange_rate])

    if @exchange_rate.save
      flash_and_redirect_to('Your exchange rate has been created successfully', :notice, administrator_exchange_rates_path)
    else
      render(:action => 'new')
    end
  end

  def edit
  end

  def update
    if @exchange_rate.update_attributes(params[:exchange_rate])
      flash_and_redirect_to('Your exchange rate has been updated successfully', :notice, administrator_exchange_rates_path)
    else
      render(:action => 'edit')
    end
  end

  def delete
  end

  def destroy
    if @exchange_rate.destroy
      flash_and_redirect_to('The exchange rate has been deleted successfully', :notice, administrator_exchange_rates_path)
    else
      render(:action => 'delete')
    end
  end

  protected

    def find_exchange_rate
      @exchange_rate = ExchangeRate.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash_and_redirect_to('The requested exchange rate does not exist', :error, administrator_exchange_rates_path)
    end

end