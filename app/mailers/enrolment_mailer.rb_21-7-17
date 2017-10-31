class EnrolmentMailer < ActionMailer::Base

  def instructor_notification(enrolment, instructor)
    @enrolment = enrolment
    @instructor = instructor
    mail(to: instructor.email, subject: 'A new student has enrolled on your course')
  end

  def student_notification(enrolment, student)
    subject = if student.enrolments.size > 1
      'Welcome back to The Compelling Image'
    else
      'Welcome to The Compelling Image'
    end
    @enrolment = enrolment
    @student = student
    @instructors = course_instructors(@enrolment.scheduled_course.course)
    @instructors_first_name = course_instructor_name(@enrolment.scheduled_course.course)
    mail(to: student.email, subject: subject)
  end

  # Find all course instructors
  def course_instructors(course)
    str  = ''
    names = course.instructors.map{|i| i.full_name}
    names.each_with_index do |n, i|
      if names.count == i+1
        str << "#{n}'s"
      elsif names.count-1 == i+1
        str << "#{n} and "
      else
        str << "#{n}, "
      end
    end
    str
  end

  def course_instructor_name(course)
    str  = ''
    names = course.instructors.map{|i| i.given_name}
    names.each_with_index do |n, i|
      if names.count == i+1
        str << "#{n}"
      elsif names.count-1 == i+1
        str << "#{n} and "
      else
        str << "#{n}, "
      end
    end
    str
  end

end
