class ScheduledCourseMailer < ActionMailer::Base

  def course_start_instructor_reminder(scheduled_course, instructor)
    @scheduled_course = scheduled_course
    @instructor = instructor
    mail(to: instructor.email, subject: 'A new course starts today!')
  end

end
