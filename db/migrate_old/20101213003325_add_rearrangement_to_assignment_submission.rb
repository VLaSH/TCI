class AddRearrangementToAssignmentSubmission < ActiveRecord::Migration
  def self.up
    add_column :assignment_submissions, :rearrangement, :text, :default => nil
  end

  def self.down
    remove_column :assignment_submissions, :rearrangement
  end
end
