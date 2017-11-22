class Instructorship < ActiveRecord::Base

  belongs_to :course
  # TODO - This association needs to be verified for syntax and expected output
  belongs_to :instructor, -> { where('users.role = ?', User::ROLES[:instructor]) }, class_name: :User, foreign_key: :instructor_user_id

  validates_presence_of :course_id, :instructor_user_id
  validates_existence_of :course, :instructor, allow_nil: true
  validates_uniqueness_of :instructor_user_id, scope: :course_id, message: 'is already an instructor'

  validate :instructor_user_must_be_instructor
  validate :course_must_not_be_deleted, :instructor_must_be_activated, on: :create

  attr_accessible *self.new.attributes.keys

  protected

    def instructor_user_must_be_instructor
      errors.add(:instructor, 'must be an instructor user') if instructor.nil? || !instructor.instructor?
    end

    def instructor_must_be_activated
      errors.add(:instructor, "#{instructor.id} must be activated") if instructor.nil? || !instructor.activated?
    end

    def course_must_not_be_deleted
      errors.add(:course, 'must not be deleted') if course.nil? || course.deleted?
    end

end
