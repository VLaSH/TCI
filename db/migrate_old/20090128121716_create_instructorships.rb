class CreateInstructorships < ActiveRecord::Migration
  def self.up
    create_table :instructorships do |t|
      t.belongs_to :course,
                   :instructor_user, :null => false
      t.timestamps
    end
    add_index :instructorships, :course_id, :name => 'idx_course_id'
    add_index :instructorships, [ :course_id, :instructor_user_id  ], :unique => true, :name => 'idx_course_id_instructor_user_id'
  end

  def self.down
    drop_table :instructorships
  end
end