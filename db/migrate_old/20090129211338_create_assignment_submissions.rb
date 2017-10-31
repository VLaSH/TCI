class CreateAssignmentSubmissions < ActiveRecord::Migration
  def self.up
    create_table :assignment_submissions do |t|
      t.belongs_to :assignment,
                   :enrolment, :null => false
      t.string     :title, :null => false
      t.text       :summary
      t.text       :description, :limit => 5592405   # number of 3 byte characters in a mediumtext field
      t.boolean    :completed, :null => false, :default => false
      t.datetime   :deleted_at
      t.timestamps
    end
    add_index :assignment_submissions, :enrolment_id, :name => 'idx_enrolment_id'
    add_index :assignment_submissions, [ :assignment_id, :enrolment_id ], :name => 'idx_assignment_id_enrolment_id'
  end

  def self.down
    drop_table :assignment_submissions
  end
end