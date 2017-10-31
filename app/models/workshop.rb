class Workshop < ActiveRecord::Base
  acts_as_deletable
  acts_as_money

  belongs_to :instructor_1, class_name: :User
  belongs_to :instructor_2, class_name: :User
  belongs_to :instructor_3, class_name: :User
  belongs_to :instructor_4, class_name: :User

  [1, 2, 3, 4, 5, 6].each do |i|
    has_attached_file "photo_#{i}".to_sym,
                      TciWorkshopPhoto.worshop_photo_credential(i).merge({
                      :styles => { :small  => '35x35#',
                                   :medium => '75x75#',
                                   :large  => '115x115#',
                                   :hero   => '195x195#',
                                   :w160xh120 => '160x120#',
                                   :w660xh230 => '660x230#',
                                   :w660xh390 => '660x390#',
                                   :w660xh440 => '660x440#' }})

    has_deletable_attachment "photo_#{i}".to_sym

    validates_attachment_content_type "photo_#{i}".to_sym, :content_type => config.paperclip.image_content_types
    validates_attachment_size "photo_#{i}".to_sym, :less_than => config.course.maximum_photo_size
  end

  money :full_price, currency: :full_price_currency, cents: :full_price_in_cents
  money :deposit_price, currency: :deposit_price_currency, cents: :deposit_price_in_cents
  money :balance_price, currency: :balance_price_currency, cents: :balance_price_in_cents
  money :supplement_price, currency: :supplement_price_currency, cents: :supplement_price_in_cents
  
  attr_accessible :title, :summary, :description, :enrolment, :upcoming, :terms, :full_price_in_cents, :full_price_currency,
    :full_price, :deposit_price_in_cents, :deposit_price_currency, :deposit_price,:balance_price_in_cents, :balance_price_currency, :balance_price, :supplement_price_in_cents, :supplement_price_currency, :supplement_price,:photo_1, :photo_2, :photo_3, :photo_4,
    :photo_5, :photo_6, :page_title, :vimeo_video_id, :instructor_1_id, :instructor_1, :instructor_2_id, :instructor_2,
    :instructor_3_id, :instructor_3, :instructor_4_id, :instructor_4, :instructor_5_id, :instructor_5, :instructor_6_id, :instructor_6,
    :visible, :youtube_video_id

  validates_presence_of :title, :full_price

  with_options allow_blank: true do |o|
    o.validates_length_of :title, maximum: 255
    o.validates_length_of :summary, maximum: 65535
    o.validates_length_of :description, maximum: 16777215
  end

  with_options only_integer: true do |o|
    o.validates_numericality_of :full_price_in_cents, greater_than_or_equal_to: 0
    o.validates_numericality_of :deposit_price_in_cents, greater_than_or_equal_to: 0
    o.validates_numericality_of :balance_price_in_cents, greater_than_or_equal_to: 0
    o.validates_numericality_of :supplement_price_in_cents, greater_than_or_equal_to: 0
  
  end

  validates_format_of :full_price_currency, with: /\A[A-Z]{3}\Z/
  validates_format_of :deposit_price_currency, with: /\A[A-Z]{3}\Z/
  validates_format_of :balance_price_currency, with: /\A[A-Z]{3}\Z/
  validates_format_of :supplement_price_currency, with: /\A[A-Z]{3}\Z/

  scope :visible, -> { where(:visible => true) }

  def to_param
    "#{id}-#{title.downcase.gsub(/[\W!\-]+/, ' ').strip.gsub(/[–]/, '-').gsub(/\ +/, '-').gsub(/-+/, '-').gsub(/^-|-$/, '')}"
  end

  def photo_s3_url(photo, style = nil, expires_in = 1.hour)
    if Rails.application.config.s3_configuration
      AWS::S3::S3Object.url_for(photo.path(style || photo.default_style), photo.bucket_name, :expires_in => expires_in, :use_ssl => photo.s3_protocol == 'https')
    else
      photo.url(style)
    end
  end
end
