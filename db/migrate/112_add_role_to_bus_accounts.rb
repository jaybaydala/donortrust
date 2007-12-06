class AddRoleToBusAccounts < ActiveRecord::Migration
  def self.up
    add_column "bus_accounts", :role, :string, :limit => 20
    add_index "bus_accounts", :role
  end

  def self.down
    remove_column "bus_accounts", :role
  end
end