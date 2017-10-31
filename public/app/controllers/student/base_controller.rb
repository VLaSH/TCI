class Student::BaseController < ApplicationController

  layout 'student'
  before_filter :require_student_user
  before_filter :setup_page
  
protected

  def setup_page
    page_config do |page|
      page.body_tag_options[:class] = 'student'
      page.primary_navigation_section = :student_area
      page.secondary_navigation = true
      page.title.unshift('Student Area')
    end
  end

end