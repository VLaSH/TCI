class StudentGallery < ActiveRecord::Base
  attr_accessible :creator, :course, :image
  has_attached_file :image,
                    STUDENTGALLERY_IMAGE.merge(
                    styles: { thumb: "100x65>", gallery: "316x180>",
                      detail: { geometry: Proc.new { |a| a.send(:geometry_string_with_orientation, 660, 440) }, format: :png }
                      })

  validates :image, :attachment_presence => true
  validates_presence_of :creator, :course
  validates_attachment_content_type :image, content_type: config.paperclip.image_content_types

  has_deletable_attachment :image

  def s3_url(style = nil, expires_in = 1.hour)
    if Rails.application.config.s3_configuration
      AWS::S3::S3Object.url_for(path(style || image.default_style), image.bucket_name, :expires_in => expires_in, :use_ssl => image.s3_protocol == 'https')
    else
      image.url(style)
    end
  end

  def geometry_string_with_orientation(width, height)
      geometry = (video? ? Paperclip::VideoGeometry : Paperclip::Geometry).from_file(asset.path) rescue nil

      case
        when !geometry.nil? && geometry.horizontal? then "#{width}x#{(width / geometry.aspect).to_i}"
        when !geometry.nil? && geometry.vertical? then "#{(height / geometry.aspect).to_i}x#{height}"
      else
        "#{width}x#{height}"
      end
    end



end
