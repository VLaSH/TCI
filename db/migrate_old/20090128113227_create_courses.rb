class CreateCourses < ActiveRecord::Migration
  def self.up
    create_table :courses do |t|
      t.string    :title, :null => false
      t.text      :summary
      t.text      :description, :limit => 5592405   # number of 3 byte characters in a mediumtext field
      t.integer   :price_in_cents, :unsigned => true, :null => false, :default => 0
      t.datetime  :starts_at, :null => false
      t.integer   :frequency, :limit => 2, :unsigned => true, :null => false
      t.string    :photo_file_name
      t.string    :photo_content_type
      t.integer   :photo_file_size, :unsigned => true
      t.datetime  :photo_updated_at,
                  :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :courses
  end
end