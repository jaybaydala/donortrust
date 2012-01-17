class AddSubscriptionIdToTaxReceipts < ActiveRecord::Migration
  def self.up
    add_column :tax_receipts, :subscription_id, :integer
  end

  def self.down
    remove_column :tax_receipts, :subscription_id
  end
end
