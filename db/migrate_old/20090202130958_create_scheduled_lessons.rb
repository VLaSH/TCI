class CreateScheduledLessons < ActiveRecord::Migration
  def self.up
    create_table :scheduled_lessons do |t|
      t.belongs_to :scheduled_course,
                   :lesson, :null => false
      t.date       :starts_on,
                   :ends_on, :null => false
      t.datetime   :deleted_at
      t.timestamps
    end
    add_index :scheduled_lessons, :scheduled_course_id, :name => 'idx_scheduled_course_id'
    add_index :scheduled_lessons, [ :lesson_id, :scheduled_course_id ], :unique => true, :name => 'idx_lesson_id_scheduled_course_id'
  end

  def self.down
    drop_table :scheduled_lessons
  end
end