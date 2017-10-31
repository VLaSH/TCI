# Methods added to this helper will be available to all templates in the application.
include ::ActionView::Helpers::PrototypeHelper
module ApplicationHelper

  def get_banner_slide_speed
    Settings.find_by(key: 'banner_slide_speed').value rescue 1000
  end

  def get_video_url
    setting = Settings.find_by(key: 'video_url')
    if setting && setting.method == '1'
      url = "https://player.vimeo.com/video/#{setting.value}"
    elsif setting && setting.method == '2'
      url = "https://www.youtube.com/embed/#{setting.value}"
    else
      ''
    end
  end

  def get_title_how_it_works_video
    setting = Settings.find_by(key: 'video_url')
    setting.present? ? setting.other : ''
  end

  def admins_section
    request.path.match(/^\/(administrator|student|instructor)+(\/|$)/)
  end

  def title_tag
    content_tag(:title, h(page_config.title.delete_if(&:blank?).join(' | ')))
  end

  def body_tag(class_name = nil, &block)
    options = page_config.body_tag_options.stringify_keys
    add_class!(options, class_name) unless class_name.blank?
    concat(content_tag(:body, capture(&block), options))
  end

  def duration_for_display(days)
    if (days % 7 ) == 0
      pluralize(days / 7, "week")
    else
      pluralize(days, "day")
    end
  end

  def whats_new_text
    @whats_new ||= File.open(File.join(Rails.root, 'config', 'locales', 'whats_new.en.txt'), "r") { |f| f.readlines.join('').gsub('\r\n', '<br>') } if File.exist?(File.join(Rails.root, 'config', 'locales', 'whats_new.en.txt'))
  end

  def whats_new_image
    @whats_new_image ||= File.exists?(File.join(Rails.root, 'public', 'images', 'whats_new.png')) ? "/images/whats_new.png" : ''
  end

  # added tag_cloud_with_styles to display all tags on tag_cloud.html.erb
  def tag_cloud_with_styles(options = {})
    options.assert_valid_keys(:limit, :conditions, :sort)
    options.reverse_merge! :sort => :name
    sort = options.delete(:sort)
    tags = Tag.where('taggings_count > 0').order('taggings_count DESC').sort_by(&sort)

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

  #this function call in view for display images
  def attachment_thumbnail(attachment, options = {})
    if !attachment.image? && !attachment.video?
      ("<p><strong>This attachment is not an image or video</strong><br />" << link_to("Download Attachment", attachment.s3_url) << "</p>").html_safe
    else
      options = { :style => options } if options.is_a?(Symbol)

      if attachment.vimeo_video_id.present? and !options[:style] == :w60xh60
        render(:partial => "attachments/vimeo", :locals => { :attachment => attachment, height: options[:height], width: options[:width] })
      elsif attachment.youtube_video_id.present? and !options[:style] == :w60xh60
        render(:partial => "attachments/youtube", :locals => { :attachment => attachment,height: options[:height], width: options[:width] })
      else
        image_options = { :alt => 'Attachment', :title => attachment.meta_data}
        image_url = (attachment.image? || attachment.video?) ? attachment.s3_url(options[:style]) : "paperclip_#{options[:style]}.gif"
        if options[:pdf] 			
           thumbnail = wicked_pdf_image_tag(image_url, image_options.merge(:id => options[:id])) #
        else
           thumbnail = image_tag(image_url, image_options.merge(:id => options[:id]))
        end
     
        if options[:lightview]
          target = case
            when attachment.vimeo_video_id.present? then "https://player.vimeo.com/video/#{ attachment.vimeo_video_id}"
            when attachment.youtube_video_id.present? then "https://www.youtube.com/embed/#{attachment.youtube_video_id}"
            when attachment.image? then attachment.s3_url()
            when attachment.video? && !attachment.completed? then image_path("paperclip_video_pending.gif")
            else            
              image_url
            end
            
          link_to(thumbnail,
                  target,
                  :class => 'lightview', :rel => 'set[gallery]',
                  :title => "#{attachment.title}::#{attachment.description}::autosize: true#{", flashvars: '&file=#{CGI::escape(attachment.s3_url(:transcoded))}'" if attachment.video?}",
                  :id => options[:id],
                  :data => { :meta_data => attachment.meta_data})
        else
          thumbnail
        end
      end
    end
  end


 def student_galleries(attachment, options = {})
    options = { :style => options } if options.is_a?(Symbol)
    options = options.reverse_merge(:lightview => false, :style => :medium, :id => nil)

    image_options = { :alt => 'Attachment', :title => "course : #{attachment.course} created by #{attachment.creator}" }
    image_url = (attachment.image? || attachment.video?) ? attachment.s3_url(options[:style]) : "paperclip_#{options[:style]}.gif"

    thumbnail = image_tag(image_url, image_options.merge(:id => options[:id])) #

    if options[:lightview]
      target = attachment.s3_url() if attachment.image?
      link_to(thumbnail, target,class: 'lightview', rel: 'set[gallery]',title: "Course: #{ attachment.course} created by #{attachment.creator}", id: options[:id])
    else
      thumbnail
    end
  end
  def sortable_element_js(element_id, options = {}) #:nodoc:
    options[:with]     ||= "Sortable.serialize(#{ActiveSupport::JSON.encode(element_id)})"
    options[:onUpdate] ||= "function(){" + remote_function(options) + "}"
    options.delete_if { |key, value| ActionView::Helpers::PrototypeHelper::AJAX_OPTIONS.include?(key) }

    [:tag, :overlap, :constraint, :handle].each do |option|
      options[option] = "'#{options[option]}'" if options[option]
    end

    options[:containment] = array_or_string_for_javascript(options[:containment]) if options[:containment]
    options[:only] = array_or_string_for_javascript(options[:only]) if options[:only]

    %(Sortable.create(#{ActiveSupport::JSON.encode(element_id)}, #{options_for_javascript(options)});)
  end

  # Show errors of object on screen.
  def error_messages(object)
    return unless object.respond_to?(:errors) && object.errors.any?
    html = <<-HTML
    <div id="error_explanation" style='color: red;'>
      <ul>#{object.errors.full_messages.map { |msg| content_tag(:li, msg) }.join}</ul>
    </div>
    HTML
    html.html_safe
  end

  # find current user all scheduled assignement which is enrolments is not unsubscribe
  def current_user_scheduleled_assignements
    enrolment = Enrolment.user_enrolments(current_user)
    scheduled_assignment = ScheduledAssignment.joins(scheduled_lesson: [scheduled_course: :enrolments]).where(scheduled_lessons: {enrolment_id: enrolment}, enrolments: {unsubscribe: false, student_user_id: current_user.id})
    scheduled_assignment

  end

  # find student login and enroll for any course
  def find_student_enroll_and_logged_in?
    if current_user.is_a?(User) && current_user.activated?
      if Enrolment.user_enrolments(current_user).size > 0
        return true
      else
        return false
      end
    else
      false
    end
  end

  def get_attachment_url(attachment, style)
    if attachment.youtube_video_id.present?
      url = "https://www.youtube.com/embed/#{attachment.youtube_video_id}"
    elsif attachment.vimeo_video_id.present?
      url = "https://player.vimeo.com/video/#{attachment.vimeo_video_id}"
    else
      url = attachment.s3_url(style[:style])
    end
  end
  private

    def add_class!(options, class_name)
      options['class'] = (options['class'] || '').split(' ').push(*class_name).uniq.join(' ')
    end
    
    

end
