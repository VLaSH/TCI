class Contest < ActiveRecord::Base

  self.per_page = 20

  has_attached_file :photo,
                    COURSE_PHOTO.merge({:styles => { :small  => '35x35#',
                                 :medium => '75x75#',
                                 :large  => '115x115#',
                                 :hero   => '195x195#',
                                 :w160xh120 => '160x120#',
                                 :w660xh230 => '660x230#',
                                 :w660xh390 => '660x390#',
                                 :w660xh440 => '660x440#' }})

  has_deletable_attachment :photo

  #after_create { |c| c.contest.save }

  attr_accessible :year, :month, :winner_name, :photo_file_name, :photo_content_type, :photo_file_size, :photo_updated_at, :winner_date, :status, :winner_prize

  validates_attachment_content_type :photo, :content_type => config.paperclip.image_content_types
  
  validates_attachment_size :photo, :less_than => config.course.maximum_photo_size

 def photo_s3_url(style = nil, expires_in = 1.hour)
    if Rails.application.config.s3_configuration
      AWS::S3::S3Object.url_for(photo.path(style || photo.default_style), photo.bucket_name, :expires_in => expires_in, :use_ssl => photo.s3_protocol == 'https')
    else
      photo.url(style)
    end
  end
end
