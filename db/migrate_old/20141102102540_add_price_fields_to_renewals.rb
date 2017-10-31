class AddPriceFieldsToRenewals < ActiveRecord::Migration

  def up
    add_column :renewals, :price_in_cents, :integer, :unsigned => true, :null => false, :default => 0
    add_column :renewals, :price_currency, :string, :limit => 3, :null => false, :default => Money.default_currency.iso_code
  end

  def down
    remove_column :renewals, :price_in_cents
    remove_column :renewals, :price_currency
  end

end
