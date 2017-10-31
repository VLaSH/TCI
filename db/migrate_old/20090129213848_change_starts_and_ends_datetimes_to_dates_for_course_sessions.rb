class ChangeStartsAndEndsDatetimesToDatesForCourseSessions < ActiveRecord::Migration
  def self.up
    change_table :course_sessions do |t|
      t.rename :starts_at, :starts_on
      t.rename :ends_at, :ends_on
      t.change :starts_on, :date, :null => false
      t.change :ends_on, :date, :null => false
    end
  end

  def self.down
    change_table :course_sessions do |t|
      t.rename :starts_on, :starts_at
      t.rename :ends_on, :ends_at
      t.change :starts_at, :datetime, :null => false
      t.change :ends_at, :datetime, :null => false
    end
  end
end