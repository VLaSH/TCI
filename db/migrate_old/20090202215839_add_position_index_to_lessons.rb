class AddPositionIndexToLessons < ActiveRecord::Migration
  def self.up
    add_index :lessons, :position, :name => 'idx_position'
  end

  def self.down
    remove_index :lessons, :name => 'idx_position'
  end
end