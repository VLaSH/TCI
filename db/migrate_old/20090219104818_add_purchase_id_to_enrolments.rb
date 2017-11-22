class AddPurchaseIdToEnrolments < ActiveRecord::Migration
  def self.up
    change_table :enrolments do |t|
      t.belongs_to :purchase
      t.index :purchase_id, :name => 'idx_purchase_id'
    end
  end

  def self.down
    change_table :enrolments do |t|
      t.remove_index :name => 'idx_purchase_id'
      t.remove :purchase_id
    end
  end
end