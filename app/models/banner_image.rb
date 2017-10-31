class BannerImage < ActiveRecord::Base
  TYPES = %w(HomeBanner HowItWorkBanner MentorshipBanner WorkshopBanner CoursePhotographyBanner CourseMultimediaBanner PortfolioBanner CourseGridSection PortfolioGridSection MentorshipGridSection StudentGalleryGridSection WhatsNewGridSection TciBlogGridSection)

  attr_accessible :image, :type
  has_attached_file :image,
                    BANNER_IMAGE.merge(
                    styles: { thumb: "100x100>", w947xh469: '947x469>', w316xh179: '316x179#'
                      })

  validates :image, :attachment_presence => true
  validate :validate_dimension, if: 'image.present?'
  validates :type, inclusion: { in: TYPES }, presence: true

  validates_attachment_content_type :image, content_type: config.paperclip.image_content_types

  has_deletable_attachment :image


  # This function validate image dimension
  def validate_dimension
    if type == 'CoursePhotographyBanner' || type == 'CourseMultimediaBanner'
      required_width, required_height = 480, 466
    elsif TYPES[7, 12].include?(type)
      required_width, required_height = 315, 178
    else
      required_width, required_height = 947, 469
    end
    dimensions = Paperclip::Geometry.from_file(image.queued_for_write[:original].path)

    errors.add(:image, "dimension must be #{required_width}x #{required_height} or above") if dimensions.width < required_width || dimensions.height < required_height
  end

  # Use S3 url
  def image_s3_url(style = nil, expires_in = 1.hour)
    if Rails.application.config.s3_configuration
      AWS::S3::S3Object.url_for(image.path(style || image.default_style), photo.bucket_name, :expires_in => expires_in, :use_ssl => image.s3_protocol == 'https')
    else
      image.url(style)
    end
  end

end
