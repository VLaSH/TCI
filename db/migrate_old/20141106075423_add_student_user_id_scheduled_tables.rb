class AddStudentUserIdScheduledTables < ActiveRecord::Migration
  def self.up
    add_column :scheduled_lessons, :student_user_id, :integer
    add_index :scheduled_lessons, :student_user_id
  end

  def self.down
    remove_column :scheduled_lessons, :student_user_id
  end
end
