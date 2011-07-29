class AddSubscriptionToCartLineItems < ActiveRecord::Migration
  def self.up
    add_column :cart_line_items, :subscription, :boolean, :default => false
  end

  def self.down
    remove_column :cart_line_items, :subscription
  end
end
