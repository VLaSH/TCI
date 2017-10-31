class Instructor::BaseController < ApplicationController

  layout 'instructor'
  before_filter :require_instructor_user
  before_filter :setup_page

  protected

    def setup_page
      page_config do |page|
        page.body_tag_options[:class] = 'instructor'
        page.primary_navigation_section = :instructor_area
        page.secondary_navigation = true
        page.title.unshift('Instructor Area')
      end
    end
end