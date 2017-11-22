class CreateCritiques < ActiveRecord::Migration
  def self.up
    create_table :critiques do |t|
      t.belongs_to :critiqueable, :null => false, :polymorphic => true
      t.belongs_to :user, :null => false
      t.text       :comment, :limit => 5592405   # number of 3 byte characters in a mediumtext field
      t.datetime   :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :critiques
  end
end