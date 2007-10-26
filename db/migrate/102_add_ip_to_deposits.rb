class AddIpToDeposits < ActiveRecord::Migration
  def self.up
    add_column :deposits, :user_ip_addr, :string, :limit=>50
  end

  def self.down
    remove_column :deposits, :user_ip_addr
  end
end
