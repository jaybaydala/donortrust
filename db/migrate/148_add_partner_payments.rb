class AddPartnerPayments < ActiveRecord::Migration
  def self.up
    create_table :partner_payments do |t|
      t.column :amount,                   :decimal, :precision => 12, :scale => 2
      t.column :payment_date,             :datetime
      t.column :payment_reference_number, :text
      t.column :partner_id,               :int
      t.column :notes,                    :text
      t.column :created_at,               :datetime
      t.column :updated_at,               :datetime
    end
  end

  def self.down
    drop_table :partner_payments
  end
end
