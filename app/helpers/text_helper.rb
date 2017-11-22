require "rubygems"
require "hpricot"

module TextHelper

  # Like the Rails _truncate_ helper but doesn't break HTML tags, entities, and optionally. words.
  def truncate_html(text, words = 15, truncate_string = "...")
    doc = Hpricot.parse(text)
    (doc/:"text()").to_s.split[0..words].join(' ') + truncate_string
  end

  # Does this look familar Bob... does it?! huh?
  def interpolate_attachments(content, attachments, width, height)
    content = content.to_s.gsub(/\{attachment(\d+)\}/i).with_index do |match, i|
      digit = match.match(/\{attachment(?<photoid>\d+)\}/)[:photoid].to_i
      attachment = attachments[digit-1]
      content_type = case
                       when attachment.nil? then ''
                       when attachment.image? then 'image'
                       when attachment.video? then 'video'
                     else
                       'download'
                     end

      unless attachment.blank?
        if attachment.vimeo_video_id.present?
          render(:partial => "attachments/vimeo", :locals => { :attachment => attachment, :attachment_index => $1, width: width, height: height })
        elsif attachment.youtube_video_id.present?
          render(:partial => "attachments/youtube", :locals => { :attachment => attachment, :attachment_index => $1, width: width, height: height })
        elsif content_type.present?
          render(:partial => "attachments/#{content_type}", :locals => { :attachment => attachment, :attachment_index => $1 })
        else
          ''
        end
      end
    end
    content.to_s.gsub(/\{vimeo\:(\d+)\}/i) do |match|
      render(:partial => "attachments/vimeo", :locals => { :vimeo_id => $1.to_i })
    end
  end

  def interpolate_pdf_attachments(content, attachments, width, height)
    content = content.to_s.gsub(/\{attachment(\d+)\}/i).with_index do |match, i|
      digit = match.match(/\{attachment(?<photoid>\d+)\}/)[:photoid].to_i
      attachment = attachments[digit-1]
      content_type = case
                       when attachment.nil? then ''
                       when attachment.image? then 'image'
                       when attachment.video? then 'video'
                     else
                       'download'
                     end

      unless attachment.blank?
        # if attachment.vimeo_video_id.present?
        #   render(:partial => "attachments/vimeo", :locals => { :attachment => attachment, :attachment_index => $1, width: width, height: height }, :formats=>[:html], :variants=>[], :handlers=>[:erb])
        # elsif attachment.youtube_video_id.present?
        #   render(:partial => "attachments/youtube", :locals => { :attachment => attachment, :attachment_index => $1, width: width, height: height }, :formats=>[:html], :variants=>[], :handlers=>[:erb])
        # els
        if content_type.present?
          render(:partial => "attachments/image_pdf", :locals => { :attachment => attachment, :attachment_index => $1 }, :formats=>[:html], :variants=>[], :handlers=>[:erb])
        else
          ''
        end
      end
    end
    content.to_s.gsub(/\{vimeo\:(\d+)\}/i) do |match|
      render(:partial => "attachments/vimeo", :locals => { :vimeo_id => $1.to_i }, :formats=>[:html], :variants=>[], :handlers=>[:erb])
    end
  end

  def instructor_interpolate_attachments(content, attachments, width, height)
    content = content.to_s.gsub(/\{attachment(\d+)\}/i).with_index do |match, i|
      digit = match.match(/\{attachment(?<photoid>\d+)\}/)[:photoid].to_i
      attachment = attachments[digit-1]
      content_type = case
                       when attachment.nil? then ''
                       when attachment.image? then 'image'
                       when attachment.video? then 'video'
                     else
                       'download'
                     end
      unless attachment.blank?
        if attachment.vimeo_video_id.present?
          render(:partial => "attachments/vimeo", :locals => { :attachment => attachment, :attachment_index => $1, width: width, height: height })
        elsif attachment.youtube_video_id.present?
          render(:partial => "attachments/youtube", :locals => { :attachment => attachment, :attachment_index => $1, width: width, height: height })
        elsif content_type.present?
          render(:partial => "attachments/#{content_type}", :locals => { :attachment => attachment, :attachment_index => $1 })
        else
          ''
        end
      end
    end
  end
end
