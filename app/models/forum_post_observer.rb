class ForumPostObserver < ActiveRecord::Observer

  def after_create(forum_post)
    #students = forum_post.forum_topic_discussable.course.enrolment_students.where('users.status="activated"').having('max(enrolments.end_date) >= now()').map(&:email)
    students = forum_post.forum_topic_discussable.course.enrolment_students.where('users.status="activated" AND enrolments.end_date >= now()').map(&:email)
    students.delete(forum_post.user.email)
 
    instructors = case forum_post.forum_topic_discussable
    when ScheduledLesson, ScheduledAssignment
      forum_post.forum_topic_discussable.course.instructors.map(&:email)
    else
     []
    end
    instructors.delete(forum_post.user.email)
    
		# if forum_post.topic.id != 1077 && forum_post.topic.id != 1079 &&  forum_post.topic.id != 1081 &&  forum_post.topic.id != 1083 &&  forum_post.topic.id != 1085 &&  forum_post.topic.id != 1084 &&  forum_post.topic.id != 1087
		# 	students.each do |recipient|
		# 		ForumPostMailer.notification(forum_post, recipient, false).deliver
		# 	end
		# end	
		
    instructors.each do |recipient|
      ForumPostMailer.notification(forum_post, recipient, true).deliver
    end
  end

end
