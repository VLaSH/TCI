class WorkshopsController < ApplicationController
  def index
    page_config do |page|
      page.body_tag_options[:class] = 'sales'
      page.body_tag_options[:id] = 'courses'
      page.primary_navigation_section = :workshops
      page.title.unshift('Workshops')
    end

    @workshops = Workshop.non_deleted.visible.paginate(page: params[:page], per_page: 6)
  end

  def show
    page_config do |page|
      page.body_tag_options[:class] = 'sales'
      page.body_tag_options[:id] = 'workshops'
      page.primary_navigation_section = :workshops
      page.title.unshift('Workshops')
    end

    @workshop = Workshop.find_by_id(params[:id])
    @instructors = @workshop.nil? ? [] : [1, 2, 3, 4].map{|i| @workshop.send("instructor_#{i}")}.compact
    @images = @workshop.nil? ? [] : [1, 2, 3, 4, 5, 6].map{|i| i if @workshop.send("photo_#{i}?")}.compact
  end

  def photo
    head(:not_found) and return if (workshop = Workshop.find_by_id(params[:id])).nil?
    style = params[:style] || :original
    redirect_to(workshop.photo_s3_url(workshop.send("photo_#{params[:offset]}".to_sym), style))
  end
end
