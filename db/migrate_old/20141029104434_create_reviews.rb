class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.text :content
      t.references :student_user, index: true
      t.references :course, index: true
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
