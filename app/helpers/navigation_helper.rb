module NavigationHelper

  %w(primary secondary tertiary).each do |level|
    module_eval <<-EOS
      def #{level}_navigation_link_to(*args, &block)
        navigation_link_to(:#{level}, *args, &block)
      end
    EOS
  end

  protected

    def navigation_link_to(level, *args, &block)
      if block_given?
        name, section, options, html_options = capture(&block), args.first, args.second, args.third
      else
        name, section, options, html_options = args.first, args.second, args.third, args.fourth
      end

      if page_config.send("#{level}_navigation_section?", section)
        html_options = (html_options || {}).stringify_keys
        add_class!(html_options, 'current')
        name = content_tag(:strong, name) unless level == :primary || level == :secondary || level == :tertiary || block_given?
      end

      html = content_tag(:li, link_to(name, options), html_options)
      block_given? ? concat(html) : html
    end

end