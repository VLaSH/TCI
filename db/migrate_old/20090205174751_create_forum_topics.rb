class CreateForumTopics < ActiveRecord::Migration
  def self.up
    create_table :forum_topics do |t|
      t.belongs_to :user, :null => false
      t.belongs_to :discussable, :polymorphic => true
      t.string     :title, :null => false
      t.text       :content, :limit => 5592405   # number of 3 byte characters in a mediumtext field
      t.integer    :posts_count, :null => false, :unsigned => true, :default => 0
      t.datetime   :deleted_at
      t.timestamps
    end
    add_index :forum_topics, :user_id, :name => 'idx_user_id'
    add_index :forum_topics, [ :discussable_type, :discussable_id ], :name => 'idx_discussable_type_discussable_id'
  end

  def self.down
    drop_table :forum_topics
  end
end