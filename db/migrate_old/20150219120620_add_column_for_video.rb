class AddColumnForVideo < ActiveRecord::Migration
  def self.up
    add_column :attachments, :vimeo_video_id, :string
    add_column :attachments, :youtube_video_id, :string
  end
end
