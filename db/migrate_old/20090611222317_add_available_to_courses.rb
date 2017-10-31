class AddAvailableToCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :available, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :courses, :available
  end
end