class RemoveIndexFromScheduledLesson < ActiveRecord::Migration
  def self.up
    remove_index :scheduled_lessons, name: :idx_lesson_id_scheduled_course_id_user_id
  end
end
