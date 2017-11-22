class CreateBannerImages < ActiveRecord::Migration
  def change
    create_table :banner_images do |t|
      t.attachment :image
      t.timestamps
    end
  end
end
