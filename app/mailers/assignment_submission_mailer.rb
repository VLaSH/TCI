class AssignmentSubmissionMailer < ActionMailer::Base

  def completed_instructor_notification(assignment_submission, instructor)
    @assignment_submission = assignment_submission
    @instructor = instructor
    mail(to: instructor.email, subject: 'An assignment has been completed by one of your students')
  end

  # This method send to all assignment_submission instructors after Attachment has been changed.
  def attachment_changed_notification(assignment_submission)
    @assignment_submission = assignment_submission
    mail(to: @assignment_submission.instructors.pluck(:email), subject: 'An assignment has been updated.') rescue nil
  end

end
