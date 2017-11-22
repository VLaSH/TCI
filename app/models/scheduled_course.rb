class ScheduledCourse < ActiveRecord::Base

  belongs_to :course

  with_options dependent: :destroy do |o|
    o.has_many :enrolments, -> { where(deleted_at: nil) }
    # o.has_many :deleted_enrolments, -> { where("#{quoted_column_name('deleted_at')} IS NOT NULL")}, class_name: :Enrolment
    o.has_many :deleted_enrolments, -> { where("scheduled_courses.deleted_at IS NOT NULL")}, class_name: :Enrolment
    o.has_many :purchases, -> { where(status: 'completed') }
  end

  has_many :student_enrolments,  -> { where(deleted_at: nil) }, class_name: :Enrolment

  # has_many :subscribed_purchases, -> { joins(:enrolments).where(status: 'completed').where.not(unsubscribe: true) }, class_name: :Purchase, foreign_key: :purchase_id

  with_options dependent: :destroy do |o|
    o.has_many :scheduled_lessons,-> { where( deleted_at: nil) }
    # o.has_many :deleted_scheduled_lessons, -> { where("#{quoted_column_name('deleted_at')} IS NOT NULL")}, class_name: :ScheduledLesson
    o.has_many :deleted_scheduled_lessons, -> { where("scheduled_courses.deleted_at IS NOT NULL")}, class_name: :ScheduledLesson

  end

  has_many :students, -> { where("users.status = 'activated' and enrolments.unsubscribe != ?", true) }, through: :enrolments

  acts_as_deletable

  attr_accessible :duration

  validates_presence_of :course_id
  validates_existence_of :course, allow_nil: true
  validates_inclusion_of :system, in: [ true, false ], message: 'is invalid'

  validate :course_must_not_be_deleted, on: :create

  delegate :duration, :title, to: :course, allow_nil: true


  # replace the above except method to class method.
  # but rails 4 has its own except method to exclude the change call.
  def self.except(ids)
    where.not(id: ids)
  end

  scope :active, -> { all }

  scope :enrollable, ->(user) {
    user.is_a?(User) ? where("NOT EXISTS (SELECT id FROM enrolments WHERE enrolments.scheduled_course_id = id AND enrolments.student_user_id = ? AND deleted_at IS NULL)", user.id) : where('created' >= ?', Date.current - 1.week)
  }

  scope :enrolled, -> { where("(SELECT count(*) FROM enrolments WHERE enrolments.scheduled_course_id = scheduled_courses.id AND enrolments.deleted_at IS NULL) > ?", 0 ) }

  scope :empty, ->  { where("(SELECT count(*) FROM enrolments WHERE enrolments.scheduled_course_id = scheduled_courses.id AND enrolments.deleted_at IS NULL) = ?", 0 ) }

  scope :for_instructor, -> (user)  { where("(SELECT count(*) FROM instructorships WHERE instructorships.course_id = scheduled_courses.course_id AND instructorships.instructor_user_id = ?) > 0", user.id ) }

  scope :system, -> { where(system: true) }
  scope :available, ->  { where(deleted_at: nil) }

  def active?
    true
  end

  def complete?
    !ends_on.nil? && Date.current > ends_on
  end

  def enrolled?(scheduled_course, user)
    #students.include?(user)
    user == :guest ? student = nil : student = user.id
    Enrolment.active(scheduled_course, student)
  end

  alias_method :student?, :enrolled?

  def enrollable?(scheduled_course, user)
    #!deleted? && !course.nil? && course.enrollable?(user) && !enrolled?(user)
    !deleted? && !course.nil? && course.enrollable?(user) && enrolled?(scheduled_course, user).blank?
  end


  def reschedule!(now_starts_on)
    if (next_course = self.course.scheduled_courses.around(now_starts_on - (self.course.frequency.days + 1), now_starts_on + (self.course.frequency.days + 1)).except(self.id)).empty?
      offset = now_starts_on - self.created_at
      scheduled_lessons.each {|sl| sl.reschedule!(offset)}
      self.save
    else
      self.delete!
    end
  end

  def current_enrolment(user)
    enrolments.where(student_user_id: user.id).where.not(unsubscribe: true).first
  end

  def can_unsubscribe?(user)
    return (0..7).include?(Time.zone.now.to_date - current_enrolment(user).created_at.to_date) if current_enrolment(user)
    false
  end

  protected

    def course_must_not_be_deleted
      errors.add(:course, 'must not be deleted') unless course.nil? || !course.deleted?
    end

end
