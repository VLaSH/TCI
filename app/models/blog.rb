class Blog < ActiveRecord::Base

  self.per_page = 20

  has_many :images, :dependent => :destroy

  has_attached_file :photo,
                    COURSE_PHOTO.merge({:styles => { :small  => '35x35#',
                                 :medium => '75x75#',
                                 :large  => '115x115#',
                                 :hero   => '195x195#',
                                 :w160xh120 => '160x120#',
                                 :w660xh230 => '660x230#',
                                 :w660xh390 => '660x390#',
                                 :w660xh440 => '660x440#' }})

  has_attached_file :banner_photo,
                    COURSE_PHOTO.merge({:styles => { :small  => '35x35#',
                                 :medium => '75x75#',
                                 :large  => '115x115#',
                                 :hero   => '195x195#',
                                 :w160xh120 => '160x120#',
                                 :w660xh230 => '660x230#',
                                 :w660xh390 => '660x390#',
                                 :w660xh440 => '660x440#',
                                 :w1200xh360 => '1200x360#' }})

  has_deletable_attachment :photo

  attr_accessible :title, :content, :photo, :banner_photo, :page_title,  :hidden, :meta_description, :meta_keywords, :vimeo_video_id

  validates_presence_of :title, :content

  with_options :allow_blank => true do |o|
    o.validates_length_of :title, :maximum => 255
    o.validates_length_of :content, :maximum => 16777215
  end


  validates_attachment_content_type :photo, :content_type => config.paperclip.image_content_types
  validates_attachment_content_type :banner_photo, :content_type => config.paperclip.image_content_types
  validates_attachment :banner_photo, dimensions:{ width:1200, height:360}

  

  validates_inclusion_of :available, :in => [ true, false ], :message => 'is invalid'

  # This default scope filter deleted course
  default_scope { where(deleted_at: nil)}
  scope :visible, -> { where(:hidden => false)}
  scope :random,  -> { where("deleted_at is null").order('RAND()')}
  scope :available, -> { where(:available => true) }


  def schedule_for!(starts_on, system = false)
    scheduled_courses.create!(:starts_on => starts_on) { |s| s.system = system }
  end

  def free?
    price_in_cents == 0
  end

  def attachable?(user)
    user.administrator? || instructor?(user)
  end

  def instructor?(user)
    instructors.include?(user)
  end

  def instructable?(user)
    !deleted? && !instructor?(user)
  end

  def discussable?(user)
    !deleted?
  end

  def enrollable?(user)
    !deleted? && available?
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

  def current_price(user_id)
    new_renewal(user_id).blank? ? self.price : new_renewal(user_id).price
  end

  def new_renewal(user_id)
    subscription_count = scheduled_course.enrolments.where(student_user_id: user_id).count
    if subscription_count > 0
      renewals_list = renewals.order('created_at ASC')
      renewals_list[subscription_count].blank? ? renewals_list.last : renewals_list[subscription_count]
    end
  end

  def current_duration(user_id)
    new_renewal(user_id).blank? ? self.duration : new_renewal(user_id).duration
  end

  def enrolled?(user)
    students.include?(user)
  end

  alias_method :student?, :enrolled?

  # This method fetch the current running enrollment for this course and given user.
  def existing_enrolment(user)
    if user.kind_of?(User)
      enrolments.where('student_user_id = ? AND scheduled_course_id = ? AND DATE(end_date) >= DATE(?) AND unsubscribe = (?) ', user.id, scheduled_course.id, Time.zone.now.end_of_day, false).first
    else
      nil
    end
  end

  def can_enrollable?(user)
    # !deleted? && !starts_on.nil? && (Date.current <= starts_on + 4.week) && !course.nil? && course.enrollable?(user) && !enrolled?(user)
    enrollable?(user) && !enrolled?(user)
  end

  # This method checks, is course can renew or not.
  def can_renew?(user)
    enrolled?(user) && existing_enrolment(user).try(:in_renewal_span?)
  end

  # This method checks that is lessons are not empty.
  def has_lessons?
    !lessons.count.zero?
  end


end
