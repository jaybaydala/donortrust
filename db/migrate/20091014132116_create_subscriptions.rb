# t.decimal  "total",                                  :precision => 12, :scale => 2
# t.decimal  "account_balance_payment",                :precision => 12, :scale => 2
# t.decimal  "credit_card_payment",                    :precision => 12, :scale => 2
# t.string   "card_number",               :limit => 4
# t.string   "cvv",                       :limit => 5
# t.integer  "expiry_month"
# t.integer  "expiry_year"
# t.string   "cardholder_name"
# t.string   "authorization_result"
# t.integer  "order_number"
# t.integer  "user_id"
# t.boolean  "complete"
# t.datetime "created_at"
# t.datetime "updated_at"
# t.decimal  "gift_card_payment",                      :precision => 12, :scale => 2
# t.integer  "gift_card_payment_id"
# t.decimal  "pledge_account_payment",                 :precision => 12, :scale => 2
# t.integer  "pledge_account_payment_id"
# t.integer  "is_registration",           :limit => 1
# t.integer  "registration_fee_id"

class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.integer :user_id
      
      t.string :donor_type
      t.string :title
      t.string :first_name
      t.string :last_name
      t.string :company
      t.string :address
      t.string :address2
      t.string :city
      t.string :country
      t.string :province
      t.string :postal_code
      t.string :email

      t.string :card_number, :limit => 4
      t.string :cvv, :limit => 5
      t.integer :expiry_month
      t.integer :expiry_year
      t.string  :cardholder_name
      t.string :customer_code

      t.decimal :amount, :precision => 12, :scale => 2

      t.boolean :reoccurring_status # ON,OFF
      t.date :begin_date
      t.date :end_date
      t.string  :schedule_type # monthly, weekly
      t.integer :schedule_date # monthly:1-31; weekly:1-7
    end
    create_table :subscription_line_items do |t|
      t.integer :subscription_id
      t.string :item_type
      t.text :item_attributes
      t.timestamps
    end
  end

  def self.down
    drop_table :subscription_line_items
    drop_table :subscriptions
  end
end
