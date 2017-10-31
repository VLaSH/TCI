class Partner < ActiveRecord::Base
  mount_uploader :logo, LogoUploader, validate_integrity: true, validate_processing: true
  
  attr_accessible :name,
                  :description,
                  :logo, 
                  :remote_logo_url, 
                  :logo_cache, 
                  :remove_logo,
                  :url
                  
  validates_presence_of :name, :description
end
