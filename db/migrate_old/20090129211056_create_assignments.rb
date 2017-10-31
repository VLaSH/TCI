class CreateAssignments < ActiveRecord::Migration
  def self.up
    create_table :assignments do |t|
      t.belongs_to :lesson, :null => false
      t.string     :title, :null => false
      t.text       :summary
      t.text       :description, :limit => 5592405   # number of 3 byte characters in a mediumtext field
      t.integer    :duration, :limit => 2, :unsigned => true, :null => false
      t.integer    :position, :unsigned => true, :null => false, :default => 0
      t.datetime   :deleted_at
      t.timestamps
    end
    add_index :assignments, :lesson_id, :name => 'idx_lesson_id'
  end

  def self.down
    drop_table :assignments
  end
end