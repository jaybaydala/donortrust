class AddOfflineFundPaymentToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :offline_fund_payment, :decimal, :precision => 12, :scale => 2
  end

  def self.down
    remove_column :orders, :offline_fund_payment
  end
end
