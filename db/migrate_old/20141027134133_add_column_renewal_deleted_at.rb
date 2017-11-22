class AddColumnRenewalDeletedAt < ActiveRecord::Migration
  def self.up
    add_column :renewals, :deleted_at, :datetime
  end

  def self.down
    remove_column :renewals, :deleted_at
  end
end
