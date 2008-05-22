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
      t.decimal :total, :precision => 12, :scale => 2
      t.decimal :account_balance_total, :precision => 12, :scale => 2
      t.decimal :credit_card_total, :precision => 12, :scale => 2
      t.string  :credit_card,   :limit => 4
      t.string  :csc,           :limit => 5
      t.integer :expiry_month, :limit => 2
      t.integer :expiry_year,  :limit => 4
      t.string  :cardholder_name
      t.string  :authorization_result
      t.integer :order_number
      t.integer :user_id
      t.boolean :complete
      t.timestamps
    end
    add_index "orders", ["order_number"], :name => "order_number"
    add_index "orders", ["user_id"], :name => "user_id"

    add_column :gifts, :order_id, :integer
    add_column :investments, :order_id, :integer
    add_column :deposits, :order_id, :integer
    add_column :tax_receipts, :order_id, :integer
    add_column :tax_receipts, :view_code, :integer
    add_index "gifts",        ["order_id"], :name => "order_id"
    add_index "investments",  ["order_id"], :name => "order_id"
    add_index "deposits",     ["order_id"], :name => "order_id"
    add_index "tax_receipts", ["order_id"], :name => "order_id"
  end

  def self.down
    drop_table :orders
    remove_column :gifts, :order_id
    remove_column :investments, :order_id
    remove_column :deposits, :order_id
  end
end
