class AddColumnSeduleCores < ActiveRecord::Migration
  def self.up
    add_column :scheduled_courses, :duration, :integer
  end

  def self.down
    remove_column :scheduled_courses, :duration
  end
end
