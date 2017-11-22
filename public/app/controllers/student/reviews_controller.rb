class Student::ReviewsController < ApplicationController

  layout 'student'
  before_filter :find_course
  before_filter :require_student_user, only: [:new, :create]
  before_filter :setup_page

  def new
    @review = @course.reviews.build
  end

  def create
    @review = @course.reviews.build(permit_param)
    @review.student_user_id = current_user.id
    if @review.save
      flash_and_redirect_to('You have successfully created a review', :notice, @course)
    else
      render :new
    end
  end

  def destroy
    review = @course.reviews.find(params[:id])
    if review.destroy
      redirect_to :back, notice: 'your review delete successfully.'
    else
      redirect_to student_root_path, alert: 'Sorry! unable to delete.'
    end
  end

  private
    def find_course
      @course = Course.non_deleted.find(params[:course_id])
    end

    def permit_param
      params.require(:review).permit(:content)
    end

    def setup_page
      page_config do |page|
        page.body_tag_options[:class] = 'student'
        page.primary_navigation_section = :student_area
        page.secondary_navigation = true
        page.title.unshift('Student Area')
      end
    end

end
