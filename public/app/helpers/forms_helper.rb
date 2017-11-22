module FormsHelper

  def form_required_field
    content_tag(:abbr, '*', :class => 'required', :title => 'Required information')
  end

  def form_hint(hint)
    content_tag(:p, hint, :class => 'hint')
  end

  def iso_country_select(object, method, options = {}, html_options = {})
    options = options.reverse_merge({ :include_blank => true })
    select(object, method, CountryCodes.countries_for_select('name', 'a2').sort, options, html_options)
  end

  def user_roles_select(object, method, options = {}, html_options = {})
    select(object, method, User::ROLES.keys.map { |r| [ r.to_s.titleize, r ] }, options, html_options)
  end

  def course_type_select(object, method, options = {}, html_options = {})
    options = options.symbolize_keys
    html = options.has_key?(:label) ? label_tag(object, options.delete(:label).html_safe) : ''
    html << collection_select(object, method, CourseType.all, :number, :title, options.merge(:include_blank => true), html_options)
    content_tag(:div, html, :class => 'ctrlHolder')
  end

  def course_frequency_select(object, method, options = {}, html_options = {})
    options = options.symbolize_keys
    html = options.has_key?(:label) ? label_tag(object, options.delete(:label).html_safe) : ''
    html << select(object, method, [ [ '1 week', 7 ], [ '2 weeks', 14 ], [ '3 weeks', 21 ], [ '4 weeks', 28 ], [ '5 weeks', 35 ], [ '6 weeks', 42 ], [ '7 weeks', 49 ], [ '8 weeks', 56 ], [ '9 weeks', 63 ], [ '10 weeks', 70 ], [ '11 weeks', 77 ], [ '12 weeks', 84 ] ], options, html_options)
    content_tag(:div, html, :class => 'ctrlHolder')
  end

  def course_instructor_select(object, method, options = {}, html_options = {})
    options = options.symbolize_keys
    html = options.has_key?(:label) ? label_tag(object, options.delete(:label).html_safe) : ''
    html << collection_select(object, method, User.instructor.activated.order('given_name ASC, family_name ASC'), :id, :full_name, options, html_options.merge(:multiple => true))
    content_tag(:div, html, :class => 'ctrlHolder')
  end

  def scheduled_course_select(object, method, options = {}, html_options = {})
    options = options.symbolize_keys.reverse_merge(:include_course_name => true, :user => current_user)

    html = options.has_key?(:label) ? label_tag(object, options.delete(:label).html_safe) : ''
    label_format = '%s'
    label_format << ' - %s' if options.delete(:include_course_name)

    #select_options = (options.delete(:scheduled_courses) || ScheduledCourse.non_deleted.enrollable(options[:user]).all(:include => :course, :order => "#{ScheduledCourse.quoted_table_name}.#{ScheduledCourse.quoted_column_name('starts_on')} ASC, #{Course.quoted_table_name}.#{Course.quoted_column_name('title')} ASC")).map { |s| [ label_format % [ s.starts_on.to_formatted_s(:long), s.course.title ], s.id ] }
    select_options = (options.delete(:scheduled_courses) || ScheduledCourse.non_deleted.enrollable(options[:user]).joins(:course).order("#{ScheduledCourse.quoted_table_name}.created_at ASC", "#{Course.quoted_table_name}.title ASC")).map { |s|  [label_format % [ s.created_at.to_formatted_s(:long), s.course.title] , s.id ] }
    html << select(object, method, select_options, options.except(:user), html_options)
    content_tag(:div, html.html_safe, :class => 'ctrlHolder')
  end

  def boolean_select(object, method, options = {}, html_options = {})
    options = options.symbolize_keys.reverse_merge({ :include_blank => true })
    html = options.has_key?(:label) ? label_tag(object, options.delete(:label).html_safe) : ''
    html << select(object, method, [ ['Yes', true], ['No', false] ], options, html_options)
    content_tag(:div, html, :class => 'ctrlHolder')
  end

  def purchase_gateway_radio_buttons(object, method, options = {})
    Purchase::GATEWAYS.map do |gateway|
      unless gateway == "WorldPay"
        if gateway == "Stripe"
          content_tag(:div, content_tag(:label, "#{radio_button(object, method, gateway, options)} #{gateway} (Major credit cards)".html_safe, :class => "blockLabel"))
        else
          content_tag(:div, content_tag(:label, "#{radio_button(object, method, gateway, options)} #{gateway}".html_safe, :class => "blockLabel"))
        end
      end
    end
  end

  module FormBuilderInstanceMethods
    [ :iso_country, :user_roles, :course_frequency, :course_instructor, :scheduled_course, :boolean, :course_type ].each do |method_prefix|
      define_method("#{method_prefix}_select") do |method, *args|
        options = args.first || {}
        html_options = args.second || {}
        @template.send("#{method_prefix}_select", @object_name, method, options.merge(:object => @object), html_options)
      end
    end

    def purchase_gateway_radio_buttons(method, options = {})
      @template.purchase_gateway_radio_buttons(@object_name, method, options.merge(:object => @object))
    end
  end

  def self.included(base)
    ActionView::Helpers::FormBuilder.send(:include, FormBuilderInstanceMethods)
  end

end
