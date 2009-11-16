class AddTaxReceiptRequestedToSubscriptionsAndOrders < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :tax_receipt_requested, :boolean, :default => true
    add_column :orders, :tax_receipt_requested, :boolean, :default => true
  end

  def self.down
    remove_column :orders, :tax_receipt_requested
    remove_column :subscriptions, :tax_receipt_requested
  end
end
