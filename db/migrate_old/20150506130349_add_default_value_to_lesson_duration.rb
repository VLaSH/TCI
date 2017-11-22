class AddDefaultValueToLessonDuration < ActiveRecord::Migration
  def up
    change_column :lessons, :duration, :integer, default: 0
  end

  def down
    change_column :lessons, :duration, :integer, default: 0
  end
end
