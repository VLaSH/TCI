class AddHideDatesToCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :hide_dates, :boolean, :default => false
  end

  def self.down
    remove_column :courses, :hide_dates
  end
end
