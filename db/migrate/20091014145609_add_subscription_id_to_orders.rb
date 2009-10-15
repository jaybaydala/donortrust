class AddSubscriptionIdToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :subscription_id, :integer
  end

  def self.down
    remove_column :orders, :subscription_id
  end
end
