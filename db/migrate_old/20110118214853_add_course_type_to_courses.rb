class AddCourseTypeToCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :course_type_id, :integer
  end

  def self.down
    remove_column :courses, :course_type_id
  end
end
