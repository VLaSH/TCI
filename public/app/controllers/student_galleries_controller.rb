class StudentGalleriesController < ApplicationController

  def index
    @images = StudentGallery.all

    page_config do |page|
      page.body_tag_options[:class] = 'sales'
      page.body_tag_options[:id] = 'instructors'
      page.primary_navigation_section = :student_galleries
      page.title.unshift('Student Gallery')
    end
  end
end
