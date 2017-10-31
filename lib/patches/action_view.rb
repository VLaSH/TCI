module ActionView
  module Helpers
    class InstanceTag
      # Patch the label helpers so that they:
      # - have i18n support (based on this plugin: git://github.com/iain/i18n_label.git)
      # - accept a :value option for use with the radio_button helper
      def to_label_tag(text = nil, options = {})
        options = options.stringify_keys
        name_and_id = options.dup
        add_default_name_and_id(name_and_id)
        options.delete('index')
        unless options.has_key?('for')
          if options.has_key?('value')
            pretty_tag_value = options.delete('value').to_s.gsub(/\s/, '_').gsub(/\W/, '').downcase
            options['for'] = "#{name_and_id['id']}_#{pretty_tag_value}"
          else
            options['for'] = name_and_id['id']
          end
        end
        if text.blank?
          content = method_name.humanize
          content = object.class.human_attribute_name(method_name) if object.class.respond_to?(:human_attribute_name)
        else
          content = text.to_s
        end
        label_tag(name_and_id['id'], content, options)
      end
    end
  end
end