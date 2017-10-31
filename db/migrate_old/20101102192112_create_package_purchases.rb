class CreatePackagePurchases < ActiveRecord::Migration
  def self.up
    create_table :package_purchases do |t|
      t.integer  "package_id",                    :default => 0,         :null => false, :unsigned => true
      t.integer  "student_user_id",                        :default => 0,         :null => false, :unsigned => true
      t.integer  "price_in_cents",                         :default => 0,         :null => false, :unsigned => true
      t.string   "price_currency",           :limit => 3,  :default => "USD",     :null => false
      t.string   "gateway",                  :limit => 50, :default => "",        :null => false
      t.string   "reference"
      t.string   "status",                                 :default => "pending", :null => false
      t.text     "raw_params"
      t.datetime "notification_received_at"
      t.timestamps
    end
  end

  def self.down
    drop_table :package_purchases
  end
end
