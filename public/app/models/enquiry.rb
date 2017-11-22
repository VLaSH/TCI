class Enquiry < ActiveRecord::Base
  validates_presence_of :name, :email
  attr_accessible :name, :email, :phone_number, :message
end
