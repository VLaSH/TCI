class AddVideoToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :youtube_video_id, :string, :default => "", :null => false
    add_column :users, :vimeo_video_id, :string, :default => "", :null => false
  end

  def self.down
    remove_column :users, :youtube_video_id, :default => "", :null => false
    remove_column :users, :vimeo_video_id, :default => "", :null => false
  end
end