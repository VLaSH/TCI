class Assignment < ActiveRecord::Base

  belongs_to :lesson
  has_many :rearrangements

  with_options :dependent => :destroy do |o|
    o.has_many :scheduled_assignments, -> { where(:deleted_at => nil) }
    o.has_many :deleted_scheduled_assignments, -> {where("#{quoted_column_name('deleted_at')} IS NOT NULL")}, :class_name => 'ScheduledAssignment'
  end

  acts_as_attachable
  acts_as_deletable

  attr_accessible :title, :summary, :description, :duration, :starts_after

  validates_presence_of :title

  with_options :allow_blank => true do |o|
    o.validates_length_of :title, :maximum => 255
    o.validates_length_of :summary, :maximum => 65535
    o.validates_length_of :description, :maximum => 16777215
  end


  validate :lesson_must_not_be_deleted, :on => :create

  delegate :course, :to => :lesson

  def self.schedule_for!(scheduled_lesson)
    scheduled_lesson.lesson.assignments.all.each do |assignment|
      unless scheduled_lesson.scheduled_assignments.find_by_assignment_id(assignment.id)
        scheduled_lesson.scheduled_assignments.create! { |s| s.assignment = assignment }
      end
    end
  end

  def attachable?(user)
    !deleted? && lesson.attachable?(user)
  end

  def active?
    !deleted?
  end

  protected

    def lesson_must_not_be_deleted
      errors.add(:lesson, 'must not be deleted') unless lesson.nil? || !lesson.deleted?
    end
end
