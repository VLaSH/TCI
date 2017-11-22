class AddFeePriceInCentsToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :fee_price_in_cents, :integer
  end
end
