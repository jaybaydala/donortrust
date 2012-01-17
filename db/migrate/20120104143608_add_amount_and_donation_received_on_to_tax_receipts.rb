class AddAmountAndDonationReceivedOnToTaxReceipts < ActiveRecord::Migration
  def self.up
    add_column :tax_receipts, :amount, :decimal, :precision => 12, :scale => 2
    add_column :tax_receipts, :received_on, :date
  end

  def self.down
    remove_column :tax_receipts, :received_on
    remove_column :tax_receipts, :amount
  end
end
