class Blogcomment < ActiveRecord::Base

  self.per_page = 20  
  
  attr_accessible :comment, :blog_id, :user_id

end
