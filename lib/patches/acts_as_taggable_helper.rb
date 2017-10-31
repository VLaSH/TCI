module ActsAsTaggableHelper
  # Create a link to the tag using restful routes and the rel-tag microformat
  def link_to_tag(tag)
    link_to(tag.name, course_tags_path(tag), :rel => 'tag')
  end
  
  # Generate a tag cloud of the top 100 tags by usage, uses the proposed hTagcloud microformat.
  #
  # Inspired by http://www.juixe.com/techknow/index.php/2006/07/15/acts-as-taggable-tag-cloud/
  def tag_cloud(options = {})
    options.assert_valid_keys(:limit, :conditions, :sort, :order)
    options.reverse_merge! :sort => :name
    order = options.has_key?(:order) ? options.delete(:order) : 'taggings_count DESC'
    sort = options.delete(:sort)

    tags = Tag.find(:all, options.merge(:conditions => 'taggings_count > 0', :order => order)).sort_by(&sort)
    current = Tag.find_by_id(params[:tag]) if !params.nil? && params.has_key?(:tag)
    
    html =   %(<ul class="tag_cloud">\n)
    tags.each do |tag|
      html << "<li>#{!current.nil? && (current.name == tag.name) ? tag.name : link_to(tag.name, course_tags_path(tag))}</li>"
    end
    html <<   %(</ul>)
  end
  
  def tag_cloud_with_styles(options = {})
    options.assert_valid_keys(:limit, :conditions, :sort)
    options.reverse_merge! :sort => :name
    sort = options.delete(:sort)

    tags = Tag.find(:all, options.merge(:conditions => 'taggings_count > 0', :order => 'taggings_count DESC')).sort_by(&sort)
    
    # TODO: add option to specify which classes you want and overide this if you want?
    classes = %w(popular v-popular vv-popular vvv-popular vvvv-popular)
    
    max, min = 0, 0
    tags.each do |tag|
      max = tag.taggings_count if tag.taggings_count > max
      min = tag.taggings_count if tag.taggings_count < min
    end
    
    divisor = ((max - min) / classes.size) + 1
    
    html =    %(<div class="hTagcloud">\n)
    html <<   %(  <ul class="popularity">\n)
    tags.each do |tag|
      html << %(    <li>)
      html << link_to(tag.name, course_tags_path(tag), :class => classes[(tag.taggings_count - min) / divisor]) 
      html << %(</li> \n)
    end
    html <<   %(  </ul>\n)
    html <<   %(</div>\n)
  end
end