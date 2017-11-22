class CritiqueMailer < ActionMailer::Base

  def student_notification(critique)
    @critique = critique
    mail( to: critique.critiqueable.owner.email, subject: 'You have received a new critique')
  end

  def instructor_notification(critique, instructor)
    @critique = critique
    @instructor = instructor
    mail(to: instructor.email, subject: 'You have received a new critique')
  end
end

