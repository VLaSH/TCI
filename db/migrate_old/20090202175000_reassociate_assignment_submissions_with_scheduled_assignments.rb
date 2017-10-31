class ReassociateAssignmentSubmissionsWithScheduledAssignments < ActiveRecord::Migration

  def self.up
    change_table :assignment_submissions do |t|
      t.belongs_to :scheduled_assignment, :null => false
      t.index [ :scheduled_assignment_id, :enrolment_id ], :name => 'idx_scheduled_assignment_id'
    end

    AssignmentSubmission.reset_column_information
    AssignmentSubmission.transaction do
      AssignmentSubmission.includes(:enrolment).each do |assignment_submission|
        #assignment_submission.scheduled_assignment = ScheduledAssignment.first(:joins => :scheduled_lesson, :conditions => { :assignment_id => assignment_submission.assignment_id, :scheduled_lessons => { :scheduled_course_id => assignment_submission.enrolment.scheduled_course_id } })
        assignment_submission.scheduled_assignment = ScheduledAssignment.joins(:scheduled_lesson).where(:assignment_id => assignment_submission.assignment_id).where('scheduled_lessons.scheduled_course_id = ?', assignment_submission.enrolment.scheduled_course_id)
        assignment_submission.save!
      end
    end

    change_table :assignment_submissions do |t|
      t.remove_index :name => 'idx_assignment_id_enrolment_id'
      t.remove :assignment_id
    end
  end

  def self.down
    change_table :assignment_submissions do |t|
      t.belongs_to :assignment, :null => false
      t.index [ :assignment_id, :enrolment_id ], :name => 'idx_assignment_id_enrolment_id'
    end

    AssignmentSubmission.reset_column_information
    AssignmentSubmission.transaction do
      AssignmentSubmission.all.each do |assignment_submission|
        assignment_submission.assignment_id = ScheduledAssignment.find(assignment_submission.scheduled_assignment_id).assignment_id
        assignment_submission.save!
      end
    end

    change_table :assignment_submissions do |t|
      t.remove_index :name => 'idx_scheduled_assignment_id'
      t.remove :scheduled_assignment_id
    end
  end
end