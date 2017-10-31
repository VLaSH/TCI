class ScheduledAssignmentMailer < ActionMailer::Base

  def assignment_start_student_reminder(scheduled_assignment, student)
    unless scheduled_assignment.scheduled_course.course.free?
      @scheduled_assignment = scheduled_assignment
      @student = student
      mail(to: student.email, subject: 'A new assignment starts today!')
    end
  end

  def assignment_due_student_reminder(scheduled_assignment, student)
    unless scheduled_assignment.scheduled_course.course.free?
      @scheduled_assignment = scheduled_assignment
      @student = student
      mail(to: student.email, subject: 'An assignment is due today!')
    end
  end


end
