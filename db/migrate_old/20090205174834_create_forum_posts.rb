class CreateForumPosts < ActiveRecord::Migration
  def self.up
    create_table :forum_posts do |t|
      t.belongs_to :user,
                   :forum_topic, :null => false
      t.text       :content, :limit => 5592405   # number of 3 byte characters in a mediumtext field
      t.datetime   :deleted_at
      t.timestamps
    end
    add_index :forum_posts, :user_id, :name => 'idx_user_id'
    add_index :forum_posts, :forum_topic_id, :name => 'idx_forum_topic_id'
  end

  def self.down
    drop_table :forum_posts
  end
end