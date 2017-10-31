class CreateForumTopicUsers < ActiveRecord::Migration
  def self.up
    create_table :forum_topic_users do |t|
      t.belongs_to :user, :null => false
      t.belongs_to :forum_topic, :null => false
      t.datetime   :deleted_at
      t.timestamps
    end
    add_index :forum_topic_users, :user_id, :name => 'idx_user_id'
    add_index :forum_topic_users, :forum_topic_id, :name => 'idx_forum_topic_id'
  end

  def self.down
    drop_table :forum_topic_users
  end
end