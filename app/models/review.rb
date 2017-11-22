class Review < ActiveRecord::Base
  belongs_to :student, -> { where :users => { :role => User::ROLES[:student] } }, class_name: :User, foreign_key: :student_user_id
  belongs_to :course
  validates_presence_of :content, :course_id, :student_user_id
  attr_accessible :content
  validate :student_must_be_activated, :student_user_must_be_a_student, :course_must_be_belong_to_user

  # given name of student.
  def by
    student.blank? ? 'anonymous' : student.full_name
  end

  def can_delete?(user=nil)
    return user.administrator? || (student == user) unless user == :guest
    false
  end

  protected

    def course_must_be_belong_to_user
     errors.add(:course, 'course not belong to student ') unless course.nil? || course.available

    end

    def student_user_must_be_a_student
      errors.add(:student, 'must be a student user') unless student.nil? || student.student?
    end

    def student_must_be_activated
      errors.add(:student, 'must be activated') unless student.nil? || student.activated?
    end
end

