class CreateWorkshops < ActiveRecord::Migration
  def self.up
    create_table :workshops do |t|
      t.string    :title, :null => false
      t.string    :page_title
      t.text      :summary
      t.text      :description, :limit => 5592405   # number of 3 byte characters in a mediumtext field
      t.text      :enrolment
      t.text      :upcoming
      t.text      :terms

      t.integer   :full_price_in_cents, :unsigned => true, :null => false, :default => 0
      t.string    :full_price_currency, :limit => 3, :null => false, :default => Money.default_currency.iso_code

      t.integer   :deposit_price_in_cents, :unsigned => true, :null => false, :default => 0
      t.string    :deposit_price_currency, :limit => 3, :null => false, :default => Money.default_currency.iso_code
      
      t.string    :photo_1_file_name
      t.string    :photo_1_content_type
      t.integer   :photo_1_file_size, :unsigned => true
      t.datetime  :photo_1_updated_at
      
      t.string    :photo_2_file_name
      t.string    :photo_2_content_type
      t.integer   :photo_2_file_size, :unsigned => true
      t.datetime  :photo_2_updated_at
      
      t.string    :photo_3_file_name
      t.string    :photo_3_content_type
      t.integer   :photo_3_file_size, :unsigned => true
      t.datetime  :photo_3_updated_at
      
      t.string    :photo_4_file_name
      t.string    :photo_4_content_type
      t.integer   :photo_4_file_size, :unsigned => true
      t.datetime  :photo_4_updated_at
      
      t.string    :photo_5_file_name
      t.string    :photo_5_content_type
      t.integer   :photo_5_file_size, :unsigned => true
      t.datetime  :photo_5_updated_at
      
      t.string    :photo_6_file_name
      t.string    :photo_6_content_type
      t.integer   :photo_6_file_size, :unsigned => true
      t.datetime  :photo_6_updated_at
      
      t.string    :vimeo_video_id
      
      t.integer   :instructor_1_id
      t.integer   :instructor_2_id
      t.integer   :instructor_3_id
      t.integer   :instructor_4_id
      
      t.boolean   :visible
      
      t.datetime  :deleted_at
      t.timestamps
      t.timestamps
    end
  end

  def self.down
    drop_table :workshops
  end
end
