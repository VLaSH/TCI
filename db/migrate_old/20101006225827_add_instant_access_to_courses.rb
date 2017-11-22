class AddInstantAccessToCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :instant_access, :boolean, :default => false
  end

  def self.down
    remove_column :courses, :instant_access
  end
end
