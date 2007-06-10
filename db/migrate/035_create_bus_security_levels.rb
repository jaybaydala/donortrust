class CreateBusAdminBusSecurityLevels < ActiveRecord::Migration
  def self.up
    create_table :bus_security_levels do |t|
    end
  end

  def self.down
    drop_table :bus_security_levels
  end
end
