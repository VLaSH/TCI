class AddColumnCourseType < ActiveRecord::Migration
  def self.up
    add_column :course_types, :number, :integer
  end

  def self.down
    remove_column :course_types, :number
  end
end
