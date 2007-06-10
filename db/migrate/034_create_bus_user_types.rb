class CreateBusAdminBusUserTypes < ActiveRecord::Migration
  def self.up
    create_table :bus_user_types do |t|
    end
  end

  def self.down
    drop_table :bus_user_types
  end
end
