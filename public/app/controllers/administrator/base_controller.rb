class Administrator::BaseController < ApplicationController

  layout 'administrator'
  before_filter :require_administrator_user
  before_filter :setup_page

  protected

    def setup_page
      page_config do |page|
        page.body_tag_options[:class] = 'administrator'
        page.primary_navigation_section = :administrator_area
        page.secondary_navigation = true
        page.title.unshift('Administrator Area')
      end
    end

end