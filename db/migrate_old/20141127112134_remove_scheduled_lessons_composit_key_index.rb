class RemoveScheduledLessonsCompositKeyIndex < ActiveRecord::Migration
  def self.up
    remove_index :scheduled_lessons, name: :idx_lesson_id_scheduled_course_id

    add_index :scheduled_lessons, [ :lesson_id, :scheduled_course_id, :student_user_id ], unique: true, name: :idx_lesson_id_scheduled_course_id_user_id
  end

  def self.down
    add_index :scheduled_lessons, [ :lesson_id, :scheduled_course_id ], unique: true, name: :idx_lesson_id_scheduled_course_id
    remove_index :scheduled_lessons, name: :idx_lesson_id_scheduled_course_id_user_id
  end
end
