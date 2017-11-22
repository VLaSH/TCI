class AddEnrolmentIdScheduleLesson < ActiveRecord::Migration
  def self.up
    add_column :scheduled_lessons, :enrolment_id, :integer
  end

  def self.down
    remove_column :scheduled_lessons, :enrolment_id
  end
end
