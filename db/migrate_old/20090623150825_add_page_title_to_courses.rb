class AddPageTitleToCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :page_title, :string
  end

  def self.down
    remove_column :courses, :page_title
  end
end