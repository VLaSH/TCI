class AddTypeColumnBannerImage < ActiveRecord::Migration
  def self.up
    add_column :banner_images, :type, :string, null: false
  end

  def self.down
    remove_column :banner_images, :type
  end
end
