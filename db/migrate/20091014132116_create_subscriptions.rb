class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.integer :user_id
      t.integer :project_id

      t.string :first_name
      t.string :last_name
      t.string :street_address
      t.string :city
      t.string :state
      t.string :zip_code

      t.string :card_type
      t.string :card_number
      t.string :card_expiry
      t.decimal :amount, :precision => 12, :scale => 2

      t.string :customer_code
      t.boolean :reoccurring_status # ON,OFF
      t.date :begin_date
      t.date :end_date
      t.string  :schedule_type # monthly, weekly
      t.integer :schedule_date # monthly:1-31; weekly:1-7
    end
  end

  def self.down
    drop_table :subscriptions
  end
end
