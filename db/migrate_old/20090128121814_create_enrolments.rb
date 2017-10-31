class CreateEnrolments < ActiveRecord::Migration
  def self.up
    create_table :enrolments do |t|
      t.belongs_to :course_session,
                   :student_user, :null => false
      t.datetime   :deleted_at
      t.timestamps
    end
    add_index :enrolments, :course_session_id, :name => 'idx_course_session_id'
    add_index :enrolments, [ :course_session_id, :student_user_id  ], :name => 'idx_course_session_id_student_user_id'
  end

  def self.down
    drop_table :enrolments
  end
end