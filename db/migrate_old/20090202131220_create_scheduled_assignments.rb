class CreateScheduledAssignments < ActiveRecord::Migration
  def self.up
    create_table :scheduled_assignments do |t|
      t.belongs_to :scheduled_lesson,
                   :assignment, :null => false
      t.date       :starts_on,
                   :ends_on, :null => false
      t.datetime   :deleted_at
      t.timestamps
    end
    add_index :scheduled_assignments, :scheduled_lesson_id, :name => 'idx_scheduled_lesson_id'
    add_index :scheduled_assignments, [ :assignment_id, :scheduled_lesson_id ], :unique => true, :name => 'idx_assignment_id_scheduled_lesson_id'

    # Populate scheduled lessons and assignments for each scheduled course
    ScheduledCourse.all.each { |s| Lesson.schedule_for!(s) }
  end

  def self.down
    drop_table :scheduled_assignments
  end
end