class CreateEnquiries < ActiveRecord::Migration
  def self.up
    create_table :enquiries do |t|
      t.string :name, :phone_number, :email
      t.text :message
      t.timestamps
    end
  end

  def self.down
    drop_table :enquiries
  end
end
