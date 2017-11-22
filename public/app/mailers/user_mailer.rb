class UserMailer < ActionMailer::Base

  def activation(user)
    @user = user
    mail(to: user.email, subject: 'Welcome to The Compelling Image')
  end

  def reset_password(user)
    @user = user
    mail(to: user.email, subject: 'Your password for The Compelling Image has been reset')
  end

  def subscription_end_notification(user, course)
    @user = user
    @course = course
    mail(to: user.email, subject: 'Subscription end notification')
  end

  # mail for suspend student course servises
  def suspend_course_service(data)
    data.each{|k, v| eval("@#{k.to_s} = v")}
    mail(to: @user.email, subject: 'Service Suspended')
  end

end
