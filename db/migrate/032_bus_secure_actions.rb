class BusSecureActions < ActiveRecord::Migration
  def self.up
    create_table :bus_secure_actions, :force => true do |t|
      t.column :permitted_actions,     :string
      t.column :bus_security_level_id, :int
    end
  end

  def self.down
    drop_table :bus_secure_actions
  end
end
