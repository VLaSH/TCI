class AddCategoriesToCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :category_1, :boolean, :default => 0
    add_column :courses, :category_2, :boolean, :default => 0
    add_column :courses, :category_3, :boolean, :default => 0
    add_column :courses, :category_4, :boolean, :default => 0
  end

  def self.down
    remove_column :courses, :category_1
    remove_column :courses, :category_2
    remove_column :courses, :category_3
    remove_column :courses, :category_4
  end
end
