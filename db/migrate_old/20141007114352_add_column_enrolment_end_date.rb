class AddColumnEnrolmentEndDate < ActiveRecord::Migration
  def self.up
    add_column :enrolments, :end_date, :datetime
  end

  def self.down
    remove_column :enrolments, :end_date
  end
end
