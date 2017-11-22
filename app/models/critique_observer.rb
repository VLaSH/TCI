class CritiqueObserver < ActiveRecord::Observer

  def after_create(critique)
    CritiqueMailer.student_notification(critique).deliver if critique.critiqueable.respond_to?(:owner) && critique.critiqueable.owner.student? && !critique.owner?(critique.critiqueable.owner)

    unless critique.user.instructor?
      assignment = critique.critiqueable.is_a?(AssignmentSubmission) ? critique.critiqueable.assignment : critique.critiqueable.attachable.assignment
      assignment.course.instructors.each do |instructor|
        CritiqueMailer.instructor_notification(critique, instructor).deliver
      end
    end

    true
  end

end
