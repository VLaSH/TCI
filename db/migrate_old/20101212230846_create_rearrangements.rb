class CreateRearrangements < ActiveRecord::Migration
  def self.up
    create_table :rearrangements do |t|
      t.belongs_to :assignment, :null => false
      t.string     :title, :null => false
      t.text       :summary
      t.datetime   :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :rearrangements
  end
end
