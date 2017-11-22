class RenameCourseSessionsToScheduledCourses < ActiveRecord::Migration
  def self.up
    rename_table :course_sessions, :scheduled_courses
    change_table :enrolments do |t|
      t.rename :course_session_id, :scheduled_course_id
      t.remove_index :name => 'idx_course_session_id'
      t.remove_index :name => 'idx_course_session_id_student_user_id'
      t.index :scheduled_course_id, :name => 'idx_scheduled_course_id'
      t.index [ :scheduled_course_id, :student_user_id  ], :name => 'idx_scheduled_course_id_student_user_id'
    end
  end

  def self.down
    rename_column :enrolments, :scheduled_course_id, :course_session_id
    change_table :enrolments do |t|
      t.rename :scheduled_course_id, :course_session_id
      t.remove_index :name => 'idx_scheduled_course_id'
      t.remove_index :name => 'idx_scheduled_course_id_student_user_id'
      t.index :course_session_id, :name => 'idx_course_session_id'
      t.index [ :course_session_id, :student_user_id  ], :name => 'idx_course_session_id_student_user_id'
    end
  end
end