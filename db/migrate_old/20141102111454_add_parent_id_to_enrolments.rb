class AddParentIdToEnrolments < ActiveRecord::Migration
  def up
    add_column :enrolments, :parent_id, :integer
  end

  def down
    add_column :enrolments, :parent_id, :integer
  end
end
