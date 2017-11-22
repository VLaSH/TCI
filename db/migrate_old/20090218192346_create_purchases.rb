class CreatePurchases < ActiveRecord::Migration
  def self.up
    create_table :purchases do |t|
      t.belongs_to :scheduled_course,
                   :student_user, :null => false
      t.integer    :price_in_cents, :unsigned => true, :null => false
      t.string     :price_currency, :limit => 3, :null => false, :default => Money.default_currency.iso_code
      t.string     :gateway, :limit => 50, :null => false
      t.string     :reference
      t.string     :status, :null => false, :default => 'pending'
      t.text       :raw_params
      t.datetime   :notification_received_at
      t.timestamps
    end
    add_index :purchases, :scheduled_course_id, :name => 'idx_scheduled_course_id'
    add_index :purchases, [ :scheduled_course_id, :student_user_id  ], :name => 'idx_scheduled_course_id_student_user_id'
    add_index :purchases, :status, :name => 'idx_status'
  end

  def self.down
    drop_table :purchases
  end
end