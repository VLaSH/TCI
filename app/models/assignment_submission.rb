class AssignmentSubmission < ActiveRecord::Base

  belongs_to :scheduled_assignment
  belongs_to :enrolment
  has_one :assignment, through: :scheduled_assignment
  has_one :course, through: :enrolment
  has_many :instructors, through: :course

  acts_as_attachable
  acts_as_deletable
  acts_as_critiqueable

  # scope :by_student, lambda { |user| {
  #   :include => :enrolment,
  #   :conditions => ["#{Enrolment.quoted_table_name}.id = #{AssignmentSubmission.quoted_table_name}.enrolment_id AND #{Enrolment.quoted_table_name}.student_user_id = ?", user.id] } }

  scope :by_student, -> (user) { joins(:enrolment).where("#{Enrolment.quoted_table_name}.student_user_id = ?", user.id) }

  # scope :not_by_student, lambda { |user| {
  #   :include => :enrolment,
  #   :conditions => ["#{Enrolment.quoted_table_name}.id = #{AssignmentSubmission.quoted_table_name}.enrolment_id AND #{Enrolment.quoted_table_name}.student_user_id != ?", user.id] } }
  scope :not_by_student, -> (user){ joins(:enrolment).where("#{Enrolment.quoted_table_name}.student_user_id != ?", user.id) }

  attr_accessible :title, :summary, :description, :completed, :instructor_unread

  validates_presence_of :title

  with_options :allow_blank => true do |o|
    o.validates_length_of :title, :maximum => 255
    o.validates_length_of :summary, :maximum => 65535
    o.validates_length_of :description, :maximum => 16777215
  end
  validates_inclusion_of :completed, :in => [ true, false ], :message => 'is invalid'

  validate :scheduled_assignment_must_not_be_deleted,
                     :enrolment_must_not_be_deleted,
                     :enrolment_must_not_submit_more_than_once, :on => :create

  delegate :student, :to => :enrolment, :allow_nil => true
  delegate :title, to: :course, prefix: true, allow_nil: true
  delegate :title, to: :assignment, prefix: true, allow_nil: true

  alias_method :owner, :student

  def attachable?(user)
    user.administrator? || enrolment.student == user
  end

  def critiqueable?(user)
    !scheduled_assignment.deleted? && (user.administrator? || enrolment.scheduled_course.student?(enrolment.scheduled_course.id, user) || user.instructor?)
  end

  protected

    def scheduled_assignment_must_not_be_deleted
      errors.add(:scheduled_assignment, 'must not be deleted') unless scheduled_assignment.nil? || !scheduled_assignment.deleted?
    end

    def enrolment_must_not_be_deleted
      errors.add(:enrolment, 'must not be deleted') unless enrolment.nil? || !enrolment.deleted?
    end

    def enrolment_must_not_submit_more_than_once
      errors.add(:scheduled_assignment, 'already has a submission') unless scheduled_assignment.nil? || enrolment.nil? || self.class.non_deleted.count(:conditions => { :scheduled_assignment_id => scheduled_assignment.id, :enrolment_id => enrolment.id }).zero?
    end
end
