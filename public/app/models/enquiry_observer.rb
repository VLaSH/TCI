class EnquiryObserver < ActiveRecord::Observer
  def after_save(enquiry)
    EnquiryMailer.enquiry_notification(enquiry).deliver
  end
end
