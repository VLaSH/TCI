class EnquiryMailer < ActionMailer::Base

  def enquiry_notification(enquiry)
    @enquiry = enquiry
    mail(to: 'support@thecompellingimage.com', subject: 'New Enquiry Submission')
  end
end
