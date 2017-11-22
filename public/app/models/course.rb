class Course < ActiveRecord::Base

  self.per_page = 20

  belongs_to :course_type

  has_many :instructorships
  has_many :instructors, :through => :instructorships, :class_name => 'User'
  has_many :packages, :through => :package_courses

  with_options :dependent => :destroy do |o|
    o.has_many :scheduled_courses, -> { where(deleted_at: nil) }
    o.has_one :scheduled_course, -> { where(deleted_at: nil).order('created_at DESC')}
    o.has_many :deleted_scheduled_courses, -> {where("deleted_at IS NOT NULL")}
  end

  has_many :students, through: :scheduled_course
  has_many :enrolments, through: :scheduled_course
  has_many :enrolment_students , through: :enrolments, class_name: :User, source: :student
  has_many :student_enrolments, through: :scheduled_course#, class_name: :Enrolment

  with_options :dependent => :destroy do |o|
    o.has_many :lessons, -> {where(:deleted_at => nil)}
    o.has_many :deleted_lessons, -> {where("deleted_at IS NOT NULL")}, :class_name => 'Lesson'
    o.has_many :reviews, -> {where(deleted_at: nil)}
  end

  with_options :dependent => :destroy do |o|
    o.has_many :renewals, -> {where(deleted_at: nil)}
  end

  acts_as_attachable
  acts_as_deletable
  acts_as_discussable
  acts_as_taggable
  acts_as_money

  money :price, currency: :price_currency, cents: :price_in_cents

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

  before_save do |c|
    c.starts_on = DateTime.now
    c.frequency = 0
  end

  after_create { |c| c.scheduled_courses.build.save }

  attr_accessible :title, :summary, :description, :starts_on, :frequency, :price_in_cents, :price_currency, :price, :photo, :instructor_ids, :tag_list, :available, :page_title, :instant_access, :hidden, :meta_description, :meta_keywords, :hide_dates, :course_type, :course_type_id, :portfolio_review, :vimeo_video_id, :youtube_video_id, :category_1, :category_2, :category_3, :category_4, :category_5, :duration

  validates_presence_of :title, :description, :duration

  with_options :allow_blank => true do |o|
    o.validates_length_of :title, :maximum => 255
    o.validates_length_of :summary, :maximum => 65535
    o.validates_length_of :description, :maximum => 16777215
  end

  validates_as_date :starts_on

  with_options :only_integer => true do |o|
    o.validates_numericality_of :price_in_cents, :greater_than_or_equal_to => 0
  end

  validates_format_of :price_currency, :with => /\A[A-Z]{3}\Z/

  validates_attachment_content_type :photo, :content_type => config.paperclip.image_content_types
  validates_attachment_size :photo, :less_than => config.course.maximum_photo_size

  validates_inclusion_of :available, :in => [ true, false ], :message => 'is invalid'

  # This default scope filter deleted course
  default_scope { where(deleted_at: nil)}
  scope :visible, -> { where(:hidden => false)}
  scope :random,  -> { where("deleted_at is null").order('RAND()')}
  scope :available, -> { where(:available => true) }
  #scope :limit, lambda { |num| { :limit => num } }
  scope :for_course_type, -> (ct) { where(course_type_id: ct ) }
  scope :free, -> { where(price_in_cents: 0) }

  # scope :category_1, :conditions => { :category_1 => 1 }
  scope :category_1, -> { where(category_1: 1) }
  # scope :category_2, :conditions => { :category_2 => 1 }
  scope :category_2, -> { where(category_2: 1) }
  # scope :category_3, :conditions => { :category_3 => 1 }
  scope :category_3, -> { where(category_3: 1) }
  # scope :category_4, :conditions => { :category_4 => 1 }
  scope :category_4, -> { where(category_4: 1) }
  scope :category_5, -> { where(category_5: 1) }

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
