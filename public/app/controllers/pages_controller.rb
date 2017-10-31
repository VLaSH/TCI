class PagesController < ApplicationController

  before_filter :parse_names, :require_role_permission
  layout :setup_layout

  def show

    if !(name = [ current_role, 'pages', @names ].compact.join('/').downcase).blank? && template_exists?(name)
      @testimonials =  Testimonial.limit(2).order('updated_at desc')
      render(:template => name)
    else
      head(:not_found)
    end
  end

  protected

    def parse_names
      @names = Array(params[:names]).flatten
      name, format = @names.pop.to_s.split('.')
      @names << name unless name.blank?
      params[:format] = format unless format.blank?
    end

    def require_role_permission
      send("require_#{current_role}_user") unless current_role.blank?
    end

    def setup_layout
      current_role.blank? ? 'application' : current_role
    end

  private

    def current_role
      @current_role ||= %w(administrator instructor student).include?(params[:role]) ? params[:role] : nil
    end

end