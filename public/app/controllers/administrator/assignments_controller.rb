class Administrator::AssignmentsController < Administrator::BaseController

  before_filter :find_lesson, :only => [ :index, :new, :create ]
  before_filter :find_assignment, :except => [ :index, :new, :create ]

  def index
    @assignments = @lesson.assignments.paginate(:page => params[:page])
  end

  def show
  end

  def new
    @assignment = @lesson.assignments.build
  end

  def create
    @assignment = @lesson.assignments.build(params[:assignment])

    if @assignment.save
      flash_and_redirect_to('You have successfully created a new assignment', :notice, administrator_lesson_assignments_path(@lesson))
    else
      render(:action => 'new')
    end
  end

  def edit
  end

  def update
    if @assignment.update_attributes(params[:assignment])
      flash_and_redirect_to('The assignment has been updated successfully', :notice, administrator_lesson_assignments_path(@assignment.lesson))
    else
      render(:action => 'edit')
    end
  end

  def delete
  end

  def destroy
    if @assignment.delete!
      flash_and_redirect_to('Your assignment has been deleted successfully', :notice, administrator_lesson_assignments_path(@assignment.lesson))
    else
      render(:action => 'delete')
    end
  end

  protected

    def find_lesson
      @lesson = Lesson.non_deleted.find(params[:lesson_id])
    rescue ActiveRecord::RecordNotFound
      flash_and_redirect_to('The requested lesson does not exist', :error, administrator_lessons_path)
    end

    def find_assignment
      @assignment = Assignment.non_deleted.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash_and_redirect_to('The requested assignment does not exist', :error, administrator_lessons_path)
    end

end