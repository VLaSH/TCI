class CreatePartners < ActiveRecord::Migration
  def self.up
    create_table :partners do |t|
      t.string  :name, :url
      t.text    :description, :null => false #, :default => ""
      t.string  :logo, :null => false, :default => ""
      t.timestamps
    end
  end

  def self.down
    drop_table :partners
  end
end
