class ChangeColumnStartOnAndEndOnConstraints < ActiveRecord::Migration
  def self.up
    change_column :scheduled_courses, :starts_on, :date, null: true
    change_column :scheduled_courses, :ends_on, :date, null: true
  end

  def self.down
    change_column :scheduled_courses, :starts_on, :date, null: false
    change_column :scheduled_courses, :ends_on, :date, null: false
  end
end
