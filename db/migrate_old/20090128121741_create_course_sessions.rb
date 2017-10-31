class CreateCourseSessions < ActiveRecord::Migration
  def self.up
    create_table :course_sessions do |t|
      t.belongs_to :course, :null => false
      t.datetime   :starts_at,
                   :ends_at, :null => false
      t.boolean    :system, :null => false, :default => false
      t.datetime   :deleted_at
      t.timestamps
    end
    add_index :course_sessions, :course_id, :name => 'course_id'
  end

  def self.down
    drop_table :course_sessions
  end
end