class ScheduledLesson < ActiveRecord::Base

  acts_as_deletable
  acts_as_discussable

  attr_accessible :starts_on, :student_user_id, :enrolment_id, :lesson_id, :scheduled_course_id

  belongs_to :scheduled_course
  belongs_to :lesson
  belongs_to :enrolment
  belongs_to :student, -> { where('users.role IN (?)', User::ROLES[:student]) }, class_name: :User, foreign_key: :student_user_id

  with_options dependent: :destroy do |o|
    o.has_many :scheduled_assignments, -> {where(:deleted_at => nil)}
    o.has_many :forum_topics, as: :discussable
    o.has_many :deleted_scheduled_assignments, -> {where("deleted_at IS NOT NULL")}, class_name: :ScheduledAssignment
  end

  validates_presence_of :scheduled_course_id, :lesson_id
  validates_existence_of :scheduled_course, :lesson, allow_nil: true
  #validates_uniqueness_of :lesson_id, scope: [:lesson_id,:scheduled_course_id, :student_user_id ]
  validates_as_date :ends_on, after: ->(c){ c.starts_on + 1.day }

  validate :scheduled_course_must_not_be_deleted, :lesson_must_not_be_deleted, on: :create
  scope :active, -> { where("? BETWEEN #{quoted_column_name('starts_on')} AND #{quoted_column_name('ends_on')}", Date.current) }
  scope :for_student, -> (student_id) { where(student_user_id: student_id)}
  #find recently created scheduled lesson
  scope :select_uniq, ->{where(deleted_at: nil).select("MAX(scheduled_lessons.id) as id, scheduled_course_id, lesson_id").group(:scheduled_course_id, :student_user_id, :lesson_id)}

  after_create :schedule_assignments

  delegate :course, to: :scheduled_course

  def forum_posts_count
    self.forum_topics.map{|ft| ft.posts_count}.inject(0){|sum,item| sum + item}
  end

  def title
    self.lesson.title
  end

  def active?
    !deleted? && !starts_on.nil? && !ends_on.nil? && (starts_on..ends_on).include?(Date.current)
  end

  def complete?
    !ends_on.nil? && Date.current > ends_on
  end

  def discussable?(user)
    !deleted? && (user.administrator? || (user.instructor? && course.instructor?(user)) || (user.student? && scheduled_course.student?(find_schedule_course, user)))
  end

  def find_schedule_course
    if enrolment && enrolment.scheduled_course
      enrolment.scheduled_course.id
    else
      lesson.course.scheduled_course.id
    end
  end

  def reschedule!(offset)
    self.starts_on = self.starts_on + offset
    self.ends_on = self.ends_on + offset
    scheduled_assignments.each {|sa| sa.reschedule!(offset)}
    self.save
  end

  protected

    def scheduled_course_must_not_be_deleted
      errors.add(:scheduled_course, 'must not be deleted') unless scheduled_course.nil? || !scheduled_course.deleted?
    end

    def lesson_must_not_be_deleted
      errors.add(:lesson, 'must not be deleted') unless lesson.nil? || !lesson.deleted?
    end

    def schedule_assignments
      Assignment.schedule_for!(self)
      true
    end
end
