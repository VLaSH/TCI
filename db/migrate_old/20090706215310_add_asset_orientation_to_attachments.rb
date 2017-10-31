class AddAssetOrientationToAttachments < ActiveRecord::Migration
  # Running this migration updates the new asset_orientation field but *does not* reprocess thumbnails
  def self.up
    add_column :attachments, :asset_orientation, :string, :limit => 9, :null => true
    Attachment.reset_column_information
    Attachment.transaction { Attachment.all.each { |attachment| attachment.save_without_dirty(false) if attachment.image? || attachment.video? } }
  end

  def self.down
    remove_column :attachments, :asset_orientation
  end
end