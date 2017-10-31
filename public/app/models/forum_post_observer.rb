class ForumPostObserver < ActiveRecord::Observer

  def after_create(forum_post)
    students = forum_post.forum_topic_discussable.course.enrolment_students.map(&:email)
    students.delete(forum_post.user.email)

    instructors = case forum_post.forum_topic_discussable
    when ScheduledLesson, ScheduledAssignment
      forum_post.forum_topic_discussable.course.instructors.map(&:email)
    else
      []
    end
    instructors.delete(forum_post.user.email)
    students.each do |recipient|
      ForumPostMailer.notification(forum_post, recipient, false).deliver
    end
    instructors.each do |recipient|
      ForumPostMailer.notification(forum_post, recipient, true).deliver
    end
  end

end
