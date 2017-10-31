module TheWebFellas
  class PaginationLinkRenderer < WillPaginate::LinkRenderer

    def to_html
      links = @options[:page_links] ? windowed_links : []

      links.unshift(page_link_or_span(1, 'first', @options[:first_label]),
                    page_link_or_span(@collection.previous_page, 'previous', @options[:previous_label]))
      links.push(page_link_or_span(@collection.next_page, 'next', @options[:next_label]),
                 page_link_or_span(@collection.total_pages, 'last', @options[:last_label]))

      html = links.join(@options[:separator])
      @options[:container] ? @template.content_tag(:ul, html, html_attributes) : html
    end

    protected

      def windowed_links
        visible_page_numbers.map { |n| page_link_or_span(n, (n == current_page ? 'current' : nil)) }
      end

      def visible_page_numbers
        inner_window = @options[:inner_window].to_i
        window_from = current_page - inner_window
        window_to = current_page + inner_window

        if window_to > total_pages
          window_from -= window_to - total_pages
          window_to = total_pages
        end

        if window_from < 1
          window_to += 1 - window_from
          window_from = 1
          window_to = total_pages if window_to > total_pages
        end

        (window_from..window_to).to_a
      end

      def page_link_or_span(page, span_class, text = nil)
        text ||= page.to_s
        if page && page != current_page
          page_link(page, text, :class => span_class)
        else
          page_span(page, text, :class => span_class)
        end
      end

      def page_link(page, text, attributes = {})
        @template.content_tag(:li, @template.link_to(text, url_for(page)), attributes)
      end

      def page_span(page, text, attributes = {})
        @template.content_tag(:li, text, attributes)
      end

  end
end