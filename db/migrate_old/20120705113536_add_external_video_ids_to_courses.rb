class AddExternalVideoIdsToCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :youtube_video_id, :string
    add_column :courses, :vimeo_video_id, :string    
  end

  def self.down
    remove_column :courses, :youtube_video_id
    remove_column :courses, :vimeo_video_id
  end
end
