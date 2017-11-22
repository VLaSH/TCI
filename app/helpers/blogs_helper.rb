module BlogsHelper
  def blog_hero(blog, options = {})
    options = options.symbolize_keys
    content_tag(
      :div,
      [
        content_tag(:span, "Blog", :class => "blog"),
        " ",
        content_tag(:span, "Jan 10th", :class => "date"),
        content_tag(:span, link_to(blog.title, "#"), :class => "link")
      ].join,
      :class => "blog-hero #{options[:class]} if options.has_key?(:class)"
    )
  end

  def blog_posts
    BlogPost.latest
  end
end
