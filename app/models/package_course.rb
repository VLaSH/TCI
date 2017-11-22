class PackageCourse < ActiveRecord::Base
  belongs_to :course
  belongs_to :package
end
