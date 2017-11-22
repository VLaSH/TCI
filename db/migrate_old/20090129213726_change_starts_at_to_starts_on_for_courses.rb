class ChangeStartsAtToStartsOnForCourses < ActiveRecord::Migration
  def self.up
    change_table :courses do |t|
      t.rename :starts_at, :starts_on
      t.change :starts_on, :date, :null => false
    end
  end

  def self.down
    change_table :courses do |t|
      t.rename :starts_on, :starts_at
      t.change :starts_at, :datetime, :null => false
    end
  end
end