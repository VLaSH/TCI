class AddPaymentIdToPurchases < ActiveRecord::Migration
  def up
    add_column :purchases, :payment_id, :string
  end

  def down
    remove_column :purchases, :payment_id
  end
end
