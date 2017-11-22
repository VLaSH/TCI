class AddFieldsToCourseType < ActiveRecord::Migration
  def self.up
    add_column :course_types, :homepage_description, :string
    add_column :course_types, :course_page_title, :string
    add_column :course_types, :course_page_description, :text
  end

  def self.down
    remove_column :course_types, :course_page_description
    remove_column :course_types, :course_page_title
    remove_column :course_types, :homepage_description
  end
end
