class Administrator::SettingsController < Administrator::BaseController

  def index
    @settings = Settings.all.where.not(key: 'video_url')
  end

  def edit
    @setting = Settings.find(params[:id])
  end

  def update
    @setting = Settings.find(params[:id])
    if @setting.update_attributes(params[:settings])
      redirect_to administrator_settings_path, notice: 'Settings updated successfully'
    else
      render :edit
    end
  end

  # setup the page for settings
    def setup_page
      page_config do |page|
        super
        page.secondary_navigation_section = :settings
        page.title.unshift('Settings')
      end
    end

end
