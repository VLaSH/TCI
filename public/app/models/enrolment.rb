class Enrolment < ActiveRecord::Base

  belongs_to :scheduled_course
  has_one :course, through: :scheduled_course
  has_many :instructors, through: :course
  belongs_to :student, -> { where('users.role = ?', User::ROLES[:student])}, class_name: :User, foreign_key: :student_user_id
  belongs_to :purchase
  belongs_to :package_purchase

  belongs_to :parent, class_name: :Enrolment, foreign_key: :parent_id

  with_options dependent: :destroy do |o|
    o.has_many :assignment_submissions, -> { where(deleted_at: nil) }
    o.has_many :deleted_assignment_submissions, -> {where.not(deleted_at: nil)}, class_name: :AssignmentSubmission
  end
  has_many :scheduled_lessons

  acts_as_deletable
  attr_accessible :student, :student_user_id, :parent_id, :scheduled_course, :scheduled_course_id

  validates_presence_of :scheduled_course_id, :student_user_id
  validates_existence_of :scheduled_course, :student, :purchase, :package_purchase, :allow_nil => true

  validate :scheduled_course_must_be_enrollable, :student_user_must_be_a_student, :course_must_have_at_least_one_lesson
  validate :student_must_be_activated, on: :create

  before_create :set_end_date, :set_fees_and_duration

  scope :yesterday, -> { where("enrolments.created_at > ?", Date.yesterday) }
  # find all enrollments which are associated with user and not unsubscribe.
  scope :user_enrolments, -> (user) { where(student_user_id: user.id, unsubscribe: false, deleted_at: nil)}
  # Find enrolments with non repeted row and select max end_date of enrolments
  scope :select_uniq_row, ->(user){where(unsubscribe: false, deleted_at: nil, student_user_id: user).select("MAX(enrolments.id) as id, MAX(enrolments.end_date) as end_date, duration, scheduled_course_id, Max(enrolments.created_at) as created_at").group(" scheduled_course_id, student_user_id")}
  # this method find the current running enrollments for particulate user.
  scope :user_running_enrolments, -> (user) { user_enrolments(user).where('DATE(end_date) >= DATE(?)', Time.zone.now )}
  #this scope find user is active or not
  scope :active, ->(scheduled_course, user){where(student_user_id: user, scheduled_course_id: scheduled_course, unsubscribe: false, deleted_at: nil).where("DATE(end_date) > ?", Time.now + 7.day)}

  scope :subscriptions_expiring_today, -> { select('id, student_user_id, max(end_date)').where(:end_date => (Time.zone.now.beginning_of_day - 90.day)..(Time.zone.now.end_of_day - 90.day) ).group(:student_user_id) }

  scope :find_non_deleted_enrollments, -> {where(deleted_at: nil, unsubscribe: false)}

  delegate :free?, :title, :duration, to: :course, prefix: true, allow_nil: true

  after_create :schedule_for!

  #find scheduled lesson of scheduled course for student
  def scheduled_lessons_for_student(student_id)
    scheduled_course.scheduled_lessons.for_student(student_id)
  end

  def editable?(user)
    user.administrator? && assignment_submissions.size.zero?
  end

  def is_renewal?
    !self.parent_id.blank?
  end

  # This method return status.
  def status
    is_renewal? ? 'Renewal' : 'New Subscripion'
  end

  def set_end_date
    self.end_date = if is_renewal?
      self.parent.end_date + course.current_duration(student_user_id).day
    else
      Time.zone.now + scheduled_course.course.duration.day
    end
  end

  def set_fees_and_duration
    self.duration = course.duration
    self.fees = course.current_price(student_user_id).amount
  end

  # Send notification mail before 7 day
  def self.deliver_notification_mail_before_7_day
    where('DATE(end_date) = DATE(?)', (Time.zone.now - 7.days)).each do |enrolment|
      UserMailer.subscription_end_notification(enrolment.student, enrolment.course).deliver
    end
  end

  # check enrolment can unsubscribe or not.
  def can_unsubscribe?
    (0..7).include?(Time.zone.now.to_date - created_at.to_date)
  end

  # This method checks if a particular enrolment is eligible for renewal
  def renewable?(user)
    course.enrolled?(user) && in_renewal_span?
  end

  # This will check if a particualr enrollment lies withing renewal span
  def in_renewal_span?
    (0..7).include?(end_date.to_date - Time.zone.now.to_date)
  end

  # enrolment_start_date
  def start_date
    end_date - duration.days
  end


  # This will scheduled lession only for new enrollment.
  def schedule_for!
    unless self.parent_id
      starts_on = created_at
      course.lessons.all(order: :position).each do |lesson|
        unless scheduled_course.scheduled_lessons.where('lesson_id= ? and enrolment_id = ?',lesson.id, id ).first
          ScheduledLesson.create(student_user_id: self.student_user_id, enrolment_id: self.id, scheduled_course_id: scheduled_course.id, lesson_id: lesson.id )
        end
      end
    end
  end

 # update scheduled lesson on change student course
 def update_scheduledlessons
   starts_on = Time.now
   course.lessons.all(order: :position).each do |lesson|
    unless scheduled_course.scheduled_lessons.where('lesson_id= ? and enrolment_id = ?',lesson.id, id ).first
      ScheduledLesson.create(student_user_id: self.student_user_id, enrolment_id: self.id, scheduled_course_id: scheduled_course.id, lesson_id: lesson.id )
    end
  end
 end

  protected

    # This method add validation error on course when course has no lesson .
    def course_must_have_at_least_one_lesson
      if scheduled_course
        errors.add(:course, 'must have at least one lesson') if !course.nil? && course.lessons.size.zero?
      end
    end

    def student_user_must_be_a_student
      errors.add(:student, 'must be a student user') unless student.nil? || student.student?
    end

    def student_must_be_activated
      errors.add(:student, 'must be activated') unless student.nil? || student.activated?
    end

    def scheduled_course_must_be_enrollable
      errors.add(:scheduled_course, 'cannot be enrolled on at this time') if scheduled_course.nil? || !scheduled_course(true).enrollable?(scheduled_course.id, student)
    end

end
