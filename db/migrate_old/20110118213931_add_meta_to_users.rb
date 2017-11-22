class AddMetaToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :meta_description, :text, :default => nil
    add_column :users, :meta_keywords, :text, :default => nil
  end

  def self.down
    remove_column :users, :meta_description
    remove_column :users, :meta_keywords
  end
end
