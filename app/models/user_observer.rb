class UserObserver < ActiveRecord::Observer

  def after_save(user)
		UserMailer.activation(user).deliver if user.status_was_changed? && user.pending?
        #UserMailer.reset_password(user).deliver if !user.temporary_password.blank? && user.deliver_reset_password_message?
    true
  end
end
