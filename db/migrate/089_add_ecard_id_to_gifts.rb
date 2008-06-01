class AddEcardIdToGifts < ActiveRecord::Migration
  def self.up
    remove_column :gifts, :ecard
    add_column :gifts, :e_card_id, :integer
    add_index :gifts, :e_card_id
  end

  def self.down
    remove_index :gifts, :e_card_id
    remove_column :gifts, :e_card_id
    add_column :gifts, :ecard, :integer
  end
end
