class AddRegistrationFeeTable < ActiveRecord::Migration
  def self.up
    create_table :registration_fees do |t|
      t.integer  :participant_id
      t.integer  :order_id
      t.decimal  :amount, :precision => 12, :scale => 2
      t.boolean  :paid
      t.datetime :created_at
      t.datetime :updated_at

    end
  end

  def self.down
    drop_table :registration_fees
  end
end
