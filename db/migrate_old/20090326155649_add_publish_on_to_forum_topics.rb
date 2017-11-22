class AddPublishOnToForumTopics < ActiveRecord::Migration
  def self.up
    add_column :forum_topics, :publish_on, :datetime, :null => false
  end

  def self.down
    remove_column :forum_topics, :publish_on
  end
end