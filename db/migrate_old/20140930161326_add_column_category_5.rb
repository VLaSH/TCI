class AddColumnCategory5 < ActiveRecord::Migration
  def self.up
    add_column :courses, :category_5, :boolean, default: false
  end

  def self.down
    remove_column :courses, :category_5
  end
end
