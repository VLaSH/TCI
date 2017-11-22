class AddOtherVideoFieldUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :custom_video_code, :text
  end

  def self.down
    remove_column :users, :custom_video_code
  end
end
