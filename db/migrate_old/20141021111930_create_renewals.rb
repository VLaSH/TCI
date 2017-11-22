class CreateRenewals < ActiveRecord::Migration
  def change
    create_table :renewals do |t|
      t.integer :duration
      t.integer :amount
      t.belongs_to :course, :null => false

      t.timestamps
    end
  end
end
