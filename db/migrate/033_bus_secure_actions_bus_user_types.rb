class BusSecureActionsBusUserTypes < ActiveRecord::Migration
  def self.up
    create_table :bus_secure_actions_bus_user_types, :force => true do |t|
      t.column :bus_secure_action_id,            :int
      t.column :bus_user_type_id,           :int
    end
  end

  def self.down
    drop_table :bus_secure_actions_bus_user_types
  end
end
