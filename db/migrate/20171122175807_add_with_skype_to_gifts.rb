class AddWithSkypeToGifts < ActiveRecord::Migration
  def change
    add_column :gifts, :with_skype, :boolean, default: false
  end
end
