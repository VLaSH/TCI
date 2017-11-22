class Student::CritiquesController < Student::BaseController
  
  def new
    @assignment_submission = AssignmentSubmission.find_by_id(params[:submission_id])
    @critique = Critique.find_by_id(params[:critique_id])
    redirect_to(student_root_path) if @assignment_submission.nil? || @critique.nil?
  end
  
  def create
    @assignment_submission = AssignmentSubmission.find_by_id(params[:submission_id])
    if params[:critique][:comment].blank?
      redirect_to(student_submission_path(@assignment_submission))
    else
      @critique = Critique.find_by_id(params[:critique_id])
      @new_critique = @critique.critiqueable.critiques.build(params)
      @new_critique.user = current_user
      @new_critique.critiqueable = @critique.critiqueable
      @new_critique.comment = params[:critique][:comment]
      @new_critique.save!
      redirect_to(student_submission_path(@assignment_submission))
    end
  end

end