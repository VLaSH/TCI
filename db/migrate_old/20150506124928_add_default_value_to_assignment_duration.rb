class AddDefaultValueToAssignmentDuration < ActiveRecord::Migration
  def up
    change_column :assignments, :duration, :integer, default: 0
  end

  def down
    change_column :assignments, :duration, :integer, default: 0
  end
end
