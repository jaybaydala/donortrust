class AddIsRegistrationFlagToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :is_registration, :tinyint
    add_column :orders, :registration_fee_id, :integer
  end

  def self.down
    remove_column :orders, :is_registration
    remove_column :orders, :registration_fee_id
  end
end
