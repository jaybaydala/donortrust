class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.string  :donor_type
      t.string  :title
      t.string  :first_name
      t.string  :last_name
      t.string  :company
      t.string  :address
      t.string  :address2
      t.string  :city
      t.string  :country
      t.string  :province
      t.string  :postal_code
      t.string  :email
      t.decimal  :total, :precision => 12, :scale => 2
      t.decimal  :account_balance_total, :precision => 12, :scale => 2
      t.decimal  :credit_card_total, :precision => 12, :scale => 2
      t.string  :credit_card
      t.string  :csc
      t.string  :card_expiry
      t.string  :cardholder_name
      t.string  :authorization_result
      t.integer :order_number
      t.integer :user_id
    end
    add_index "orders", ["order_number"], :name => "order_number"
    add_index "orders", ["user_id"], :name => "user_id"
  end

  def self.down
    drop_table :orders
  end
end
