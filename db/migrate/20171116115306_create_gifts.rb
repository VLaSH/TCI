class CreateGifts < ActiveRecord::Migration
  def change
    create_table :gifts do |t|
      t.integer :lessons_amount, null: false
      t.integer :price_in_cents, null: false
      t.text :description
      t.string :title, null: false
      t.integer :category, null: false
      t.references :course

      t.timestamps null: false
    end
  end
end
