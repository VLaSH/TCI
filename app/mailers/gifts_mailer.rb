class GiftsMailer < ActionMailer::Base
  def notify_buyer(user_gift, user)
    with_skype = user_gift.with_skype ? 'with Skype session' : ''
    @user_name = "#{user.given_name} #{user.family_name}"
    pdf = WickedPdf.new.pdf_from_string(
      render_to_string template: 'gifts_mailer/pdf_template.html.erb', locals: {name: @user_name, lessons_amount: user_gift.lessons_amount, with_skype: with_skype}
    )

    attachments['gift-purchase-certificate.pdf'] = pdf
    mail(to: user.email, subject: 'Gift purchase')
  end

  def notify_recipient(user_gift)
    @coupon_code = user_gift.coupon_code
    @user_name = user_gift.recipient_name
    mail(to: user_gift.recipient_email, subject: 'New gift')
  end
end
