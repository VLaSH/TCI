class ScheduledAssignmentObserver < ActiveRecord::Observer

  def after_create(scheduled_assignment)
    forum_topic = scheduled_assignment.forum_topics.new(
      :title => scheduled_assignment.assignment.title,
      :content => "This topic is for discussing the assignment '#{scheduled_assignment.assignment.title}' for the lesson #{scheduled_assignment.scheduled_lesson.lesson.position} - '#{scheduled_assignment.scheduled_lesson.lesson.title}' - on the '#{scheduled_assignment.scheduled_lesson.lesson.course.title}' course. Please feel free to discuss this lesson here with your instructor and classmates - only people in your course session can see this content.")
    user = scheduled_assignment.scheduled_lesson.course.instructors.first
    user = User.find(2) if user.nil?
    forum_topic.user = user
    forum_topic.save!
    true
  end

end