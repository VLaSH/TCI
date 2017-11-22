class PackagesController < ApplicationController

  helper :users

  def index
    page_config do |page|
      page.body_tag_options[:class] = 'sales'
      page.body_tag_options[:id] = 'packages'
      page.primary_navigation_section = :packages
      page.title.unshift('Packages')
    end

    sort_fields = {'t' => 'title ASC', 'p' => 'price_in_cents ASC'}
    @options = params
    params.delete(:action)
    params.delete(:controller)
    @sort = params.has_key?(:s) && ['t', 'p'].include?(params[:s]) ? params[:s] : 't'
    finder_options = { :page => params[:page], :order => "#{sort_fields[@sort]}", :per_page => 6 }
    @packages = Package.non_deleted.page(params[:page]).order("#{sort_fields[@sort]}")
    # @packages = Package.non_deleted.paginate(finder_options)
  end

  def show
    @package = Package.find_by_id(params[:id])
    
    page_config do |page|
      page.body_tag_options[:class] = 'sales'
      page.body_tag_options[:id] = 'package'
      page.primary_navigation_section = :packages
      !@package.nil? ? @package.page_title.blank? ? page.title.unshift(@package.title) : page.title = @package.page_title : page.title.unshift("Package")
    end
    
  rescue ActiveRecord::RecordNotFound
    flash_and_redirect_to('The requested package does not exist', :error, packages_path)
  end
  
  def photo
    head(:not_found) and return if (package = Package.find_by_id(params[:id])).nil?
    style = params[:style] || :original
    redirect_to(package.photo_s3_url(style))
  end

end