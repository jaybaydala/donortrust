class AddPledgeAccountPaymentToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :pledge_account_payment, :decimal, :precision => 12, :scale => 2
    add_column :orders, :pledge_account_payment_id, :integer
  end

  def self.down
    remove_column :orders, :pledge_account_payment
    remove_column :orders, :pledge_account_payment_id
  end
end
