class GiftsMailer < ActionMailer::Base
  def notify_buyer(user_gift, user)
    pdf = WickedPdf.new.pdf_from_string(
      render_to_string template: 'gifts_mailer/pdf_template.html.erb', locals: {name: "#{user.given_name} #{user.family_name}", lessons_amount: user_gift.lessons_amount}
    )

    attachments['gift-purchase-certificate.pdf'] = pdf
    mail(to: user.email, subject: 'Gift purchase')
  end

  def notify_recipient(user_gift)
    @coupon_code = user_gift.coupon_code
    mail(to: user_gift.recipient_email, subject: 'New gift')
  end
end
