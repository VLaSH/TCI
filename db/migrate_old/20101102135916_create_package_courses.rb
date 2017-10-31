class CreatePackageCourses < ActiveRecord::Migration
  def self.up
    create_table :package_courses do |t|
      t.belongs_to :package
      t.belongs_to :course
      t.timestamps
    end
  end

  def self.down
    drop_table :package_courses
  end
end
