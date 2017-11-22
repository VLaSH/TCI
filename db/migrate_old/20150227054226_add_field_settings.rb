class AddFieldSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :other, :string
  end

  def self.down
    remove_column :settings, :other
  end
end
