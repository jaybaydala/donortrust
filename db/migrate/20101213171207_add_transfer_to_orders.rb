class AddTransferToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :transfer, :boolean
  end

  def self.down
    remove_column :orders, :transfer
  end
end
