class CreateLessons < ActiveRecord::Migration
  def self.up
    create_table :lessons do |t|
      t.belongs_to :course, :null => false
      t.string     :title, :null => false
      t.text       :summary
      t.text       :description, :limit => 5592405   # number of 3 byte characters in a mediumtext field
      t.integer    :duration, :limit => 2, :unsigned => true, :null => false
      t.integer    :position, :unsigned => true, :null => false, :default => 0
      t.string     :photo_file_name
      t.string     :photo_content_type
      t.integer    :photo_file_size, :unsigned => true
      t.datetime   :photo_updated_at,
                   :deleted_at
      t.timestamps
    end
    add_index :lessons, :course_id, :name => 'idx_course_id'
  end

  def self.down
    drop_table :lessons
  end
end