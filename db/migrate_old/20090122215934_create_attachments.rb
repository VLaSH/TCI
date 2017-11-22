class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :attachments do |t|
      t.belongs_to  :owner_user, :null => false
      t.belongs_to  :attachable, :polymorphic => true, :null => false
      t.string      :title
      t.text        :description, :limit => 5592405   # number of 3 byte characters in a mediumtext field
      t.integer     :position, :null => false, :unsigned => true, :default => 0
      t.string      :asset_file_name,
                    :asset_content_type
      t.integer     :asset_file_size, :unsigned => true
      t.datetime    :asset_updated_at
      t.datetime    :deleted_at
      t.timestamps
    end
    add_index :attachments, :owner_user_id, :name => 'idx_owner_user_id'
    add_index :attachments, [ :attachable_type, :attachable_id ], :name => 'idx_attachable_type_attachable_id'
    add_index :attachments, :position, :name => 'idx_position'
  end

  def self.down
    drop_table :attachments
  end
end