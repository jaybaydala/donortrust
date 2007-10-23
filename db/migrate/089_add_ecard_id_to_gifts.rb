class AddEcardIdToGifts < ActiveRecord::Migration
  def self.up
    remove_column :gifts, :ecard
    add_column :gifts, :ecard_id, :integer
    add_index :gifts, :ecard_id
  end

  def self.down
    remove_index :gifts, :ecard_id
    remove_column :gifts, :ecard_id
    add_column :gifts, :ecard, :integer
  end
end
