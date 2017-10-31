class AddMetaToCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :meta_description, :text, :default => nil
    add_column :courses, :meta_keywords, :text, :default => nil
  end

  def self.down
    remove_column :courses, :meta_description
    remove_column :courses, :meta_keywords
  end
end
