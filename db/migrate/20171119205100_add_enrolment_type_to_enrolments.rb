class AddEnrolmentTypeToEnrolments < ActiveRecord::Migration
  def change
    add_column :enrolments, :enrolment_type, :integer, default: 0
  end
end
