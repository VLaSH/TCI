class InstructorsController < ApplicationController

  helper :users

  def index
    @instructor = User.activated.instructor.visible.random.first
    @instructors = User.activated.visible.instructor.alpha
    
    page_config do |page|
      page.body_tag_options[:class] = 'sales'
      page.body_tag_options[:id] = 'instructors'
      page.primary_navigation_section = :instructors
      page.title.unshift('Instructors')
    end
  end

  def show
    @instructor = User.activated.visible.instructor.find(params[:id])
    
    page_config do |page|
      page.body_tag_options[:class] = 'sales'
      page.body_tag_options[:id] = 'instructor'
      page.primary_navigation_section = :instructors
      page.title.unshift('Instructor')
      page.title.unshift(@instructor.full_name)
    end
  rescue ActiveRecord::RecordNotFound
    flash_and_redirect_to('The requested instructor does not exist', :error, instructors_path)
  end

end