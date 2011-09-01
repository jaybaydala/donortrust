class AddCartIdToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :cart_id, :integer
  end

  def self.down
    remove_column :orders, :cart_id
  end
end
