class AddPackagePurchaseIdToEnrolments < ActiveRecord::Migration
  def self.up
    add_column :enrolments, :package_purchase_id, :integer
  end

  def self.down
    remove_column :enrolments, :package_purchase_id
  end
end
