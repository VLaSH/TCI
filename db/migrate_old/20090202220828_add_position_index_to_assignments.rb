class AddPositionIndexToAssignments < ActiveRecord::Migration
  def self.up
    add_index :assignments, :position, :name => 'idx_position'
  end

  def self.down
    remove_index :assignments, :name => 'idx_position'
  end
end