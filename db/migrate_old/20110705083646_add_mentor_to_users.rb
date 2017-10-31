class AddMentorToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :mentor, :boolean
  end

  def self.down
    remove_column :users, :mentor
  end
end
