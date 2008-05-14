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
      t.string  :amount
      
      t.string  :account_balance_total
      t.string  :credit_card_total
      t.string  :credit_card
      t.string  :csc
      t.string  :card_expiry
      t.string  :cardholder_name
      t.string  :authorization_result
    end
  end

  def self.down
    drop_table :orders
  end
end
