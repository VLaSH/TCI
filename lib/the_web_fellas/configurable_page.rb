# Helper class to centralise page settings
module TheWebFellas
  module ConfigurablePage

    def self.included(base)
      base.send(:helper_method, :page_config) if base.respond_to?(:helper_method)
    end

    def page_config
      @page_config ||= ::TheWebFellas::ConfigurablePage::PageConfiguration.new
      block_given? ? yield(@page_config) : @page_config
    end

    class PageConfiguration

      def initialize
        @configuration = {
          :title => [ "" ],
          :body_tag_options => {},
          :primary_navigation_section => :home,
          :secondary_navigation => false,
          :secondary_navigation_section => :dashboard,
          :tertiary_navigation => false,
          :tertiary_navigation_section => nil }
      end

      def title=(value)
        @configuration[:title] = [ *value ].flatten
      end

      def body_tag_options=(value)
        raise ArgumentError, 'value must be a hash' unless value.nil? || value.is_a?(Hash)
        @configuration[:body_tag_options] = value.nil? ? {} : value.symbolize_keys
      end

      [ :primary_navigation_section, :secondary_navigation_section, :tertiary_navigation_section ].each do |attr_name|
        define_method("#{attr_name}?") do |value|
          send("#{attr_name}") == value
        end
      end

      protected

        def method_missing(name, *args)
          key = name.to_s
          case
            when @configuration.has_key?(key.to_sym) then @configuration[key.to_sym]
            when key.ends_with?('=') then @configuration[key.chop.to_sym] = args.first
            when key.ends_with?('?') then ![ nil, false ].include?@configuration[key.chop.to_sym]
          else
            super
          end
        end
    end

  end
end