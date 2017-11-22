module UniForm #:nodoc:
  module UniFormHelper
    # sets UniFormBuilder as the form builder of choice and sets the form html class to include uniForm
    [:form_for, :fields_for, :form_remote_for, :remote_form_for].each do |meth|
      src = <<-end_src
        def uni_#{meth}(object_name, *args, &proc)
          options = args.last.is_a?(Hash) ? args.pop : {}
          Rails.logger.info('------------------------------------------')
          Rails.logger.info(options.to_yaml)
          Rails.logger.info('------------------------------------------')
          options.update(:html => {}) unless options.has_key?(:html)
          Rails.logger.info('------------------------------------------')
          Rails.logger.info(options.to_yaml)
          Rails.logger.info('------------------------------------------')
          options.update(:html => options[:html].merge({:class => [options[:html][:class], 'uniForm'].compact.join(' ')}))
          Rails.logger.info('------------------------------------------')
          Rails.logger.info(options.to_yaml)
          Rails.logger.info('------------------------------------------')
          options.update(:builder => UniFormBuilder)
          #{meth}(object_name, *(args << options), &proc)
        end
      end_src
      module_eval src, __FILE__, __LINE__
    end

    # Returns a label tag that points to a specified attribute (identified by +method+) on an object assigned to a template
    # (identified by +object+).  Additional options on the input tag can be passed as a hash with +options+.  An alternate
    # text label can be passed as a 'text' key to +options+.
    def label_for(object_name, method, options = {})
      label = options[:text] ? options.delete(:text) : method.to_s.humanize
      options = options.stringify_keys
      # add_default_name_and_id(options)
      options.delete('name')
      options['for'] = options.delete('id')
      content_tag 'label', (options.delete('required') ? "<em>*</em> ".html_safe : "") + label, options
      # ActionView::Helpers::InstanceTag.new(object_name, method, self, options.delete(:object)).to_uni_form_label_tag(label, options)
    end
  end

  # module LabeledInstanceTag #:nodoc:
  #   def to_uni_form_label_tag(text = nil, options = {})
  #     options = options.stringify_keys
  #     add_default_name_and_id(options)
  #     options.delete('name')
  #     options['for'] = options.delete('id')
  #     content_tag 'label', (options.delete('required') ? "<em>*</em> " : "") + text, options
  #   end
  # end

  module FormBuilderMethods #:nodoc:
    def label_for(method, options = {})
     @template.label_for(@object_name, method, options.merge(:object => @object))
    end
  end

  class UniFormBuilder < ActionView::Helpers::FormBuilder #:nodoc:
    (%w(date_select) + ActionView::Helpers::FormHelper.instance_methods - %w(label_for hidden_field form_for fields_for)).each do |instance_method|
      field_classname = ['text_field', 'password_field'].include?(instance_method) ? "textInput" : ['file_upload'].include?(instance_method) ? "fileUpload" : nil
      label_classname = ['check_box', 'radio_button'].include?(instance_method) ? "inlineLabel" : nil

      src = <<-end_src
        def #{instance_method}(method, options = {})
          label_options = "#{label_classname}".blank? ? {} : {:class => "#{label_classname}"}
          field_classname = ["#{field_classname}", options[:class]].compact.join(" ")
          render_field(method, options, super(method, clean_options(options.merge(:class => field_classname))), label_options)
        end
      end_src
      class_eval src, __FILE__, __LINE__
    end

    def submit(value = "Save changes", options = {})
      options.stringify_keys!
      if disable_with = options.delete("disable_with")
        options["onclick"] = "this.disabled=true;this.value='#{disable_with}';this.form.submit();#{options["onclick"]}"
      end

      @template.content_tag :div,
        @template.content_tag(:button, value, { "type" => "submit", "name" => "commit", :class => "submitButton"}.update(options.stringify_keys)),
        :class => "buttonHolder"
    end

    def radio_button(method, tag_value, options = {})
      render_field(method, options, super(method, tag_value, options))
    end

    def collection_select(method, collection, value_method, text_method, options = {}, html_options = {})
      render_field(method, options, super(method, collection, value_method, text_method, options, html_options.merge(:class => "selectInput")))
    end

    def select(method, choices, options = {}, html_options = {})
      render_field(method, options, super(method, choices, options, html_options))
    end

    def country_select(method, priority_countries = nil, options = {}, html_options = {})
      render_field(method, options, super(method, priority_countries, options, html_options))
    end

    def time_zone_select(method, priority_zones = nil, options = {}, html_options = {})
      render_field(method, options, super(method, priority_zones, options, html_options))
    end

    def hidden_field(method, options={})
      super
    end

    def fieldset(*args, &proc)
      raise ArgumentError, "Missing block" unless block_given?
      options = args.last.is_a?(Hash) ? args.pop : {}

      content =  @template.capture(&proc)
      content = @template.content_tag(:legend, options[:legend]) + content if options.has_key? :legend

      classname = options[:class]
      classname = "" if classname.nil?
      classname << " " << (options[:type] == ("inline" || :inline) ? "inlineLabels" : "blockLabels")

      options.delete(:legend)
      options.delete(:type)

      @template.concat(@template.content_tag(:fieldset, content, options.merge({ :class => classname.strip })))

    end

    def ctrl_group(&proc)
      raise ArgumentError, "Missing block" unless block_given?

      @ctrl_group = true
      content = @template.capture(&proc)
      @template.concat(@template.content_tag(:div, content, :class => "ctrlHolder"))
      @ctrl_group = nil
    end

    def error_messages(options={})
      obj = @object || @template.instance_variable_get("@#{@object_name}")
      count = obj.errors.count
      unless count.zero?
        html = {}
        [:id, :class].each do |key|
          if options.include?(key)
            value = options[key]
            html[key] = value unless value.blank?
          else
            html[key] = 'errorMsg'
          end
        end
        header_message = "Ooops!"
        error_messages = obj.errors.full_messages.map {|msg| @template.content_tag(:li, msg) }
        @template.content_tag(:div,
          @template.content_tag(options[:header_tag] || :h3, header_message) <<
            @template.content_tag(:p, 'There were problems with the following fields:') <<
            @template.content_tag(:ul, error_messages),
          html
        )
      else
        ''
      end
    end

    def info_message(options={})
      sym = options[:sym] || :uni_message
      @template.flash[sym] ? @template.content_tag(:p, @template.flash[sym], :id => "OKMsg") : ''
    end

    def messages
       error_messages + info_message
    end

  private

    def render_field(method, options, field_tag, base_label_options = {})
      label_options = { :required => options.delete(:required) }
      label_options.update(base_label_options)
      label_options.update(:text => options.delete(:label)) if options.has_key?(:label)

      obj = @object || @template.instance_variable_get("@#{@object_name}")
      errors = obj.errors[method]

      #divContent = errors.nil? ? "" : @template.content_tag('p', errors.class == Array ? errors.first : errors, :class => "errorField")

      unless errors.blank?
        label_options.update(:text => [label_options[:text], errors.is_a?(Array) ? errors.first : errors].compact.join(" "))
        label_options.update(:class => [label_options[:class], "errorField"].compact.join(" "))
      end

      wrapperClass = 'ctrlHolder'
      wrapperClass << ' col' if options.delete(:column)
      wrapperClass << options.delete(:ctrl_class) if options.has_key? :ctrl_class
      wrapperClass << ' error' if errors.present?

      divContent = label_for(method, label_options) + field_tag
      divContent << @template.content_tag('p', options.delete(:hint), :class => 'formHint') if options.has_key?(:hint) && !options[:hint].blank?

      if not @ctrl_group
        @template.content_tag('div', divContent, :class => wrapperClass)
      else
        divContent
      end
    end

    def clean_options(options)
      options.reject { |key, value| key == :required or key == :label or key == :hint or key == :column or key == :ctrl_class}
    end

  end
end
