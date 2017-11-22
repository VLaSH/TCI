class ForumTopicUser < ActiveRecord::Base
  acts_as_deletable
  
  belongs_to :forum_topic
  belongs_to :user
end