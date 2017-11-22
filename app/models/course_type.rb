class CourseType < ActiveRecord::Base
  has_many :courses
  attr_accessible :title, :homepage_description, :course_page_title, :course_page_description, :number

end
