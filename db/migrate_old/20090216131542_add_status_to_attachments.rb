class AddStatusToAttachments < ActiveRecord::Migration
  def self.up
    change_table :attachments do |t|
      t.string :status, :limit => 1, :null => false, :default => 'n'
      t.index  :status, :name => 'idx_status'
    end
  end

  def self.down
    change_table :attachments do |t|
      t.remove_index :name => 'idx_status'
      t.remove :status
    end
  end
end