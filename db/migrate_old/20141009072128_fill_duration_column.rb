class FillDurationColumn < ActiveRecord::Migration
  def self.up
    ScheduledCourse.where(duration: nil).each do | s |
      s.duration = s.course.frequency
      s.save
    end
  end
end
