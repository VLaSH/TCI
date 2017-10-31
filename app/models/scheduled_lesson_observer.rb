class ScheduledLessonObserver < ActiveRecord::Observer

  def after_create(scheduled_lesson)
    forum_topic = scheduled_lesson.forum_topics.new(
      :title => scheduled_lesson.lesson.title,
      :content => "This topic is for discussing lesson #{scheduled_lesson.lesson.position} - '#{scheduled_lesson.lesson.title}' - on the '#{scheduled_lesson.lesson.course.title}' course. Please feel free to discuss this lesson here with your instructor and classmates - only people in your course session can see this content.")
    user = scheduled_lesson.course.instructors.first
    forum_topic.user = user
    forum_topic.save!
    true
  end

end