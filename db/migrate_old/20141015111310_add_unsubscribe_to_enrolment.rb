class AddUnsubscribeToEnrolment < ActiveRecord::Migration
  def change
    add_column :enrolments, :unsubscribe, :boolean, default: false
  end
end
