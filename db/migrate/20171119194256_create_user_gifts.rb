class CreateUserGifts < ActiveRecord::Migration
  def change
    create_table :user_gifts do |t|
      t.references :gift, null: false
      t.string :recipient_email, null: false
      t.string :recipient_name, null: false
      t.boolean :is_used, default: false
      t.integer :status, default: 0
      t.integer :coupon_code, null: false
      t.date :notify_on, default: Date.today

      t.timestamps null: false
    end
  end
end
