class AddAddOptionalDonationToCarts < ActiveRecord::Migration
  def self.up
    add_column :carts, :add_optional_donation, :boolean, :default => true
  end

  def self.down
    remove_column :carts, :add_optional_donation
  end
end
