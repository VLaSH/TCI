class AddHiddenToCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :hidden, :boolean, :default => false
  end

  def self.down
    remove_column :courses, :hidden
  end
end
