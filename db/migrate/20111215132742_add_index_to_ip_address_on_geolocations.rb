class AddIndexToIpAddressOnGeolocations < ActiveRecord::Migration
  def self.up
    add_index :geolocations, :ip_address
  end

  def self.down
    remove_index :geolocations, :ip_address
  end
end
