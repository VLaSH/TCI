class EnrolmentObserver < ActiveRecord::Observer

  def after_create(enrolment)
    enrolment.course.instructors.each { |instructor| EnrolmentMailer.instructor_notification(enrolment, instructor).deliver }
    EnrolmentMailer.student_notification(enrolment, enrolment.student).deliver

    enrolment.scheduled_lessons_for_student(enrolment.student_user_id).each do |scheduled_lesson|
      ft = ForumTopic.find_by_discussable_type_and_discussable_id('ScheduledLesson', scheduled_lesson.id)
      create_forum_topic_user(ft, enrolment.student) unless ft.nil?
      scheduled_lesson.scheduled_assignments.each do |scheduled_assignment|
        ft = ForumTopic.find_by_discussable_type_and_discussable_id('ScheduledAssignment', scheduled_assignment.id)
        create_forum_topic_user(ft, enrolment.student) unless ft.nil?
      end
    end
    true
  end

  def after_update(enrolment)
    # repeated code ahoy - wet as they come
    if enrolment.deleted_at_was_changed? && enrolment.deleted_at.nil?
      enrolment.scheduled_lessons_for_student(enrolment.student_user_id).each do |scheduled_lesson|
        ft = ForumTopic.find_by_discussable_type_and_discussable_id('ScheduledLesson', scheduled_lesson.id)
        create_forum_topic_user(ft, enrolment.student) unless ft.nil?
        scheduled_lesson.scheduled_assignments.each do |scheduled_assignment|
          ft = ForumTopic.find_by_discussable_type_and_discussable_id('ScheduledAssignment', scheduled_assignment.id)
          create_forum_topic_user(ft, enrolment.student) unless ft.nil?
        end
      end    elsif enrolment.deleted_at_was_changed? && !enrolment.deleted_at.nil?
      enrolment.scheduled_lessons_for_student(enrolment.student_user_id).each do |scheduled_lesson|
        ft = ForumTopic.find_by_discussable_type_and_discussable_id('ScheduledLesson', scheduled_lesson.id)
        delete_forum_topic_user(ft, enrolment.student) unless ft.nil?
        scheduled_lesson.scheduled_assignments.each do |scheduled_assignment|
          ft = ForumTopic.find_by_discussable_type_and_discussable_id('ScheduledAssignment', scheduled_assignment.id)
          delete_forum_topic_user(ft, enrolment.student) unless ft.nil?
        end
      end
    end
  end

  protected
    def create_forum_topic_user(topic, user)
      ftu = ForumTopicUser.new
      ftu.forum_topic = topic
      ftu.user = user
      ftu.save!
    end

    def delete_forum_topic_user(topic, user)
      ForumTopicUser.destroy_all(user_id: user.id, forum_topic_id: topic.id)
    end

end
