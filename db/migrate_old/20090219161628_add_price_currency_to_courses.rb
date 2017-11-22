class AddPriceCurrencyToCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :price_currency, :string, :limit => 3, :null => false, :default => Money.default_currency.iso_code
  end

  def self.down
    remove_column :courses, :price_currency
  end
end