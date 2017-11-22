class Package < ActiveRecord::Base

  self.per_page = 6

  with_options dependent: :destroy do |o|
    o.has_many :package_courses
    o.has_many :courses, through: :package_courses
  end

  acts_as_attachable
  acts_as_deletable
  acts_as_money

  money :price, currency: :price_currency, cents: :price_in_cents

  has_attached_file :photo,
                    PACKAGE_PHOTO.merge({:styles => { :small  => '35x35#',
                                 :medium => '75x75#',
                                 :large  => '115x115#',
                                 :hero   => '195x195#',
                                 :w160xh120 => '160x120#',
                                 :w660xh230 => '660x230#',
                                 :w660xh390 => '660x390#',
                                 :w660xh440 => '660x440#' }})

  has_deletable_attachment :photo

  attr_accessible :title, :summary, :description, :price_in_cents, :price_currency, :price, :photo, :page_title, :course_ids

  validates_presence_of :title, :price

  with_options allow_blank: true do |o|
    o.validates_length_of :title, maximum: 255
    o.validates_length_of :summary, maximum: 65535
    o.validates_length_of :description, maximum: 16777215
  end

  with_options only_integer: true do |o|
    o.validates_numericality_of :price_in_cents, greater_than_or_equal_to: 0
  end

  validates_format_of :price_currency, with: /\A[A-Z]{3}\Z/

  validates_attachment_content_type :photo, content_type: config.paperclip.image_content_types
  validates_attachment_size :photo, less_than: config.course.maximum_photo_size

  def free?
    price_in_cents == 0
  end

  def available?
    c = 0
    courses.each do |course|
      #sc = course.scheduled_courses.future.non_deleted.order(:starts_on)
      sc = course.scheduled_courses.non_deleted.order(:created_at)
      c + 1 if sc.size.zero?
    end
    c > 0 ? false : true
  end

  def schedule
    sc = []
    courses.each do |course|
      #sc << course.scheduled_courses.future.non_deleted.order(:starts_on).first
      sc << course.scheduled_courses.non_deleted.order(:created_at).first
    end
    sc
  end

  alias_method :scheduled_courses, :schedule

  def attachable?(user)
    user.administrator? || instructor?(user)
  end

  def to_param
    "#{id}-#{title.downcase.gsub(/[\W!\-]+/, ' ').strip.gsub(/[–]/, '-').gsub(/\ +/, '-').gsub(/-+/, '-').gsub(/^-|-$/, '')}"
  end

  def photo_s3_url(style = nil, expires_in = 1.hour)
    if Rails.application.config.s3_configuration
      AWS::S3::S3Object.url_for(photo.path(style || photo.default_style), photo.bucket_name, :expires_in => expires_in, :use_ssl => photo.s3_protocol == 'https')
    else
      photo.url(style)
    end
  end
end
