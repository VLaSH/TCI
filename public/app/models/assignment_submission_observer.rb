class AssignmentSubmissionObserver < ActiveRecord::Observer

  def after_update(assignment_submission)
    assignment_submission.enrolment.course.instructors.each { |instructor| AssignmentSubmissionMailer.completed_instructor_notification(assignment_submission, instructor).deliver } if assignment_submission.completed? && assignment_submission.completed_was_changed?
    true
  end

end