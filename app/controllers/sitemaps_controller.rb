class SitemapsController < ApplicationController
  def index
    @workshops = Workshop.all.non_deleted.visible
    @courses = Course.non_deleted.visible.available
    @instructors = Instructor.all
    @emerging_photographers = Package.all.non_deleted
  end
end
