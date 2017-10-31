class CreateExchangeRates < ActiveRecord::Migration
  def self.up
    create_table :exchange_rates do |t|
      t.string    :base_currency,
                  :counter_currency, :limit => 3, :null => false
      t.decimal   :rate, :precision => 10, :scale => 4, :null => false, :default => 0.0
      t.timestamps
    end
    add_index :exchange_rates, [ :base_currency, :counter_currency ], :unique => true, :name => 'idx_base_currency_counter_currency'
  end

  def self.down
    drop_table :exchange_rates
  end
end