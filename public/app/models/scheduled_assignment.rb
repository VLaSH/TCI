class ScheduledAssignment < ActiveRecord::Base

  belongs_to :scheduled_lesson
  belongs_to :assignment

  with_options class_name: :AssignmentSubmission, dependent: :destroy do |o|
    o.has_many :submissions, -> { where(deleted_at: nil) } do
      def completed_by?(user)
        any? { |s| s.student == user && s.completed? }
      end
    end
    o.has_many :deleted_submissions, -> { where("#{quoted_column_name('deleted_at')} IS NOT NULL")}
  end

  has_many :forum_topics, dependent: :destroy

  acts_as_deletable
  acts_as_discussable

  attr_accessible :starts_on

  validates_presence_of :scheduled_lesson_id, :assignment_id
  validates_existence_of :scheduled_lesson, :assignment, allow_nil: true
  # validates_as_date :ends_on, after: Proc.new { |c| c.starts_on + 1.day }
  validates_as_date :ends_on, after: ->(c) { c.starts_on + 1.day }

  validate :scheduled_lesson_must_not_be_deleted, :assignment_must_not_be_deleted, on: :create

  scope :active, -> {where("? BETWEEN #{quoted_column_name('starts_on')} AND #{quoted_column_name('ends_on')}", Date.current)}


  delegate :lesson, :course, :scheduled_course, :student, to: :scheduled_lesson


  def forum_posts_count
    self.forum_topics.map{|ft| ft.posts_count}.inject(0){|sum,item| sum + item}
  end

  def title
    self.assignment.title
  end

  def active?
    !deleted? && !starts_on.nil? && !ends_on.nil? && (starts_on..ends_on).include?(Date.current)
  end

  def complete?
    !ends_on.nil? && Date.current > ends_on
  end

  def reschedule!(offset)
    self.starts_on = self.starts_on + offset
    self.ends_on = self.ends_on + offset
    self.save
  end

  def count_submissions
    submissions.count
  end

  protected

    def scheduled_lesson_must_not_be_deleted
      errors.add(:scheduled_lesson, 'must not be deleted') unless scheduled_lesson.nil? || !scheduled_lesson.deleted?
    end

    def assignment_must_not_be_deleted
      errors.add(:assignment, 'must not be deleted') unless assignment.nil? || !assignment.deleted?
    end

end
