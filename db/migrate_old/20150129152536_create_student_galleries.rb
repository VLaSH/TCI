class CreateStudentGalleries < ActiveRecord::Migration
  def change
    create_table :student_galleries do |t|
      t.string :creator
      t.string :course
      t.attachment :image

      t.timestamps
    end
  end
end
