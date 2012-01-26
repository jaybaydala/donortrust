class CreateGeolocations < ActiveRecord::Migration
  def self.up
    create_table :geolocations do |t|
      t.string :ip_address
      t.string :country_code

      t.timestamps
    end
  end

  def self.down
    drop_table :geolocations
  end
end
