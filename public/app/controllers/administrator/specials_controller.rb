class Administrator::SpecialsController < Administrator::BaseController

  def show
  end
  
  def edit
  end

  def update
    body = params[:body]
    
    File.open(File.join(Rails.root, 'config', 'locales', 'whats_new.en.txt'), "w") do |f|
      f.write(body)
    end
    
    image_filename = File.join(Rails.root, 'public', 'images', 'whats_new.png')

    if params.has_key?(:file) && !params[:file].nil? && !params[:file].blank?
      uploaded_io = params[:file]
      File.open(image_filename, 'wb') do |file|
        file.write(uploaded_io.read)
      end
    end
    
    if params.has_key?(:remove) && params[:remove] == "1" && (uploaded_io.nil? || uploaded_io.blank?)
      File.delete(image_filename) if File.exists?(image_filename)
    end
    
    redirect_to administrator_special_path
  end
  
  protected
  
    def setup_page
      page_config do |page|
        super
        page.secondary_navigation_section = :whats_new
        page.title.unshift('Whats new')
      end
    end
  
end