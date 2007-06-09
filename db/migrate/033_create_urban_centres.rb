class CreateBusAdminUrbanCentres < ActiveRecord::Migration
  def self.up
    create_table :urban_centres do |t|
    end
  end

  def self.down
    drop_table :urban_centres
  end
end
