class AddDefaultValueToScheduledLessons < ActiveRecord::Migration
  def up
    change_column :scheduled_lessons, :starts_on, :date, :null => true
    change_column :scheduled_lessons, :ends_on, :date, :null => true
  end

  def down
    change_column :scheduled_lessons, :starts_on, :date, :null => false
    change_column :scheduled_lessons, :ends_on, :date, :null => false
  end
end
