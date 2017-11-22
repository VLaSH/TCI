class AddYoutubeIdToWorkshops < ActiveRecord::Migration
  def self.up
    add_column :workshops, :youtube_video_id, :string    
  end

  def self.down
    remove_column :workshops, :youtube_video_id
  end
end
