class AddFeesAndDurationToEnrolments < ActiveRecord::Migration
  def up
    add_column :enrolments, :fees, :decimal
    add_column :enrolments, :duration, :integer
  end

  def down
    remove_column :enrolments, :fees
    remove_column :enrolments, :duration
  end
end
