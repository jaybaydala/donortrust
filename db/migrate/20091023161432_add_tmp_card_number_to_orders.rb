class AddTmpCardNumberToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :tmp_card_number, :string, :length => 16
  end

  def self.down
    remove_column :orders, :tmp_card_number
  end
end
