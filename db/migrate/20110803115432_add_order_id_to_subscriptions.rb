class AddOrderIdToSubscriptions < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :order_id, :integer
  end

  def self.down
    remove_column :subscriptions, :order_id
  end
end
