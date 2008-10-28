class AddBalanceToGifts < ActiveRecord::Migration
  def self.up
    add_column :gifts, :balance, :decimal, :precision => 12, :scale => 2
  end

  def self.down
    remove_column :gifts, :balance
  end
end
