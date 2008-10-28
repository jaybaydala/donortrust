class ChangeOrderPaymentColumnNames < ActiveRecord::Migration
  def self.up
    rename_column :orders, :account_balance_total, :account_balance_payment
    rename_column :orders, :credit_card_total, :credit_card_payment
    add_column :orders, :gift_card_payment, :decimal, :precision => 12, :scale => 2
    add_column :orders, :gift_card_payment_id, :integer
  end

  def self.down
    rename_column :orders, :account_balance_payment, :account_balance_total
    rename_column :orders, :credit_card_payment, :credit_card_total
    remove_column :orders, :gift_card_payment
    remove_column :orders, :gift_card_payment_id
  end
end
