class CreatePackages < ActiveRecord::Migration
  def self.up
    create_table :packages do |t|
      t.string    :title, :null => false
      t.string    :page_title
      t.text      :summary
      t.text      :description, :limit => 5592405   # number of 3 byte characters in a mediumtext field
      t.integer   :price_in_cents, :unsigned => true, :null => false, :default => 0
      t.string    :price_currency, :limit => 3, :null => false, :default => Money.default_currency.iso_code
      t.string    :photo_file_name
      t.string    :photo_content_type
      t.integer   :photo_file_size, :unsigned => true
      t.datetime  :photo_updated_at,
                  :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :packages
  end
end
