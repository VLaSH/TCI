class CreateAdministratorTestimonials < ActiveRecord::Migration
  def change
    create_table :testimonials do |t|
      t.string :title
      t.text :content
      t.string :logo

      t.timestamps
    end
  end
end
