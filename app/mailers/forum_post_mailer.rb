class ForumPostMailer < ActionMailer::Base

  def notification(forum_post, recipient, instructor)
    @forum_post = forum_post
    @recipient = recipient
    @instructor = instructor
    mail(to: recipient, subject: "#{forum_post.user.full_name} has commented on \"#{forum_post.topic.title}\"")
  end

end
