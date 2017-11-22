class AddRearrangementToCritiques < ActiveRecord::Migration
  def self.up
    add_column :critiques, :original_sequence, :string
    add_column :critiques, :rearrangement_sequence, :string
  end

  def self.down
    remove_column :critiques, :original_sequence
    remove_column :critiques, :rearrangement_sequence
  end
end
