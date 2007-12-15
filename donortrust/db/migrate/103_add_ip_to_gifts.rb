class AddIpToGifts < ActiveRecord::Migration
  def self.up
    add_column :gifts, :user_ip_addr, :string, :limit=>50
  end

  def self.down
    remove_column :gifts, :user_ip_addr
  end
end
