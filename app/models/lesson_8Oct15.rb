class Lesson < ActiveRecord::Base

  belongs_to :course

  with_options dependent: :destroy do |o|
    o.has_many :assignments, -> { where(:deleted_at => nil) }
    o.has_many :deleted_assignments, -> { where("deleted_at IS NOT NULL") }, class_name: 'Assignment'
  end

  with_options dependent: :destroy do |o|
    o.has_many :scheduled_lessons, -> { where(:deleted_at => nil) }
    o.has_many :deleted_scheduled_lessons, -> { where("#{quoted_column_name('deleted_at')} IS NOT NULL") }, class_name: :ScheduledLesson
  end

  acts_as_attachable
  acts_as_deletable

  has_attached_file :photo, LESSON_IMAGE.merge(styles: { :small  => '35x35#',
   :medium => '75x75#',
   :large  => '115x115#',
   :hero   => '195x195#' })

  has_deletable_attachment :photo

  attr_accessible :title, :summary, :description, :duration, :position, :photo

  validates_presence_of :title

  with_options allow_blank: true do |o|
    o.validates_length_of :title, maximum: 255
    o.validates_length_of :summary, maximum: 65535
    o.validates_length_of :description, maximum: 16777215
  end

  with_options only_integer: true do |o|
    o.validates_numericality_of :position, greater_than_or_equal_to: 0
  end

  validates_attachment_content_type :photo, content_type: config.paperclip.image_content_types
  validates_attachment_size :photo, less_than: config.lesson.maximum_photo_size

  # validate_on_create :course_must_not_be_deleted
  validate :course_must_not_be_deleted, :on => :create

  # validate :position_must_be_unique
  validates_uniqueness_of :position, scope: [:course_id]

  default_scope { order('position ASC') }

  # This photo_s3_url function call with lesson and use with new and edit image
  # If condition work in production mode and else condition work in development mode
  def photo_s3_url(style=nil, expires_in=1.hour)
    if Rails.application.config.s3_configuration
      AWS::S3::S3Object.url_for(photo.path(style || photo.default_style), photo.bucket_name, expires_in: expires_in, use_ssl: photo.s3_protocol == 'https')
    else
      photo.url(style)
    end
  end

  def active?
    !deleted?
  end


  def attachable?(user)
    !deleted? && course.attachable?(user)
  end

  protected

    def course_must_not_be_deleted
      errors.add(:course, 'must not be deleted') unless course.nil? || !course.deleted?
    end
end
