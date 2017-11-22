module InstructorsHelper

  def instructor_image
    if @instructor
      if !@instructor.vimeo_video_id.blank?
        content_tag :iframe, nil, src: "http://player.vimeo.com/video/#{@instructor.vimeo_video_id}?title=0&amp;byline=0&amp;portrait=0&amp;color=0c88dd", width: 660, height: 440, frameborder: 0, webkitAllowFullScreen: '', mozallowfullscreen: '', allowFullScreen: ''
      elsif !@instructor.youtube_video_id.blank?
        content_tag :iframe, nil, width: 660, height: 440, src: "http://www.youtube.com/embed/#{@instructor.youtube_video_id}?rel=0", allowfullscreen: ''
      elsif @instructor.custom_video_code.present?
         @instructor.custom_video_code.html_safe
      else
        if @instructor.instructor_photo?
          image_tag(user_instructor_photo_path(:id => @instructor.id, :style => :w660xh440), :width => 660, :height => 440, :alt => @instructor.full_name)
        elsif @instructor.attachments.size > 0
          link_to(image_tag(attachment_download_path(:id => @instructor.attachments.first.id, :style => :w660xh440), :width => 660, :height => 440, :alt => @instructor.full_name), instructor_path(@instructor))
        elsif @instructor.courses.size > 0
          image_tag(course_photo_path(:id => @instructor.courses.first.id, :style => :w660xh440), :width => 660, :height => 440, :alt => @instructor.full_name)
        else
          image_tag("samples/660x230.gif")
        end
      end
    end
  end
end
