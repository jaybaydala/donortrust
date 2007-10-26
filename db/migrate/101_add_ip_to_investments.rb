class AddIpToInvestments < ActiveRecord::Migration
  def self.up
    add_column :investments, :user_ip_addr, :string, :limit=>50
  end

  def self.down
    remove_column :investments, :user_ip_addr
  end
end
