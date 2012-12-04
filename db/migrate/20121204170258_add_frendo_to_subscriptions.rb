class AddFrendoToSubscriptions < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :frendo, :boolean, :default => false
    add_column :subscriptions, :iats_customer_code, :string
  end

  def self.down
    remove_column :subscriptions, :iats_customer_code
    remove_column :subscriptions, :frendo
  end
end
