class ScheduledLessonMailer < ActionMailer::Base

  def lesson_start_student_reminder(scheduled_lesson, student)
    @scheduled_lesson = scheduled_lesson
    @student = @student
    mail(to: student.email, subject: 'A new lesson starts today!')
  end

end
