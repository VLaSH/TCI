class AddMetaDataAttachment < ActiveRecord::Migration
  def self.up
    add_column :attachments, :meta_data, :text
  end

  def self.down
    remove_column :attachments, :meta_data
  end
end
