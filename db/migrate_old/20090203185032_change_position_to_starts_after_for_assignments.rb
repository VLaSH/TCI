class ChangePositionToStartsAfterForAssignments < ActiveRecord::Migration
  def self.up
    change_table :assignments do |t|
      t.remove_index :name => 'idx_position'
      t.rename :position, :starts_after
      t.change :starts_after, :integer, :limit => 2, :unsigned => true, :null => false, :default => 1
    end
  end

  def self.down
    change_table :assignments do |t|
      t.change :starts_after, :integer, :limit => 4, :unsigned => true, :null => false, :default => 0
      t.rename :starts_after, :position
      t.index :position, :name => 'idx_position'
    end
  end
end