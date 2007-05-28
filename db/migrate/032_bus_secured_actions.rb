class BusSecuredActions < ActiveRecord::Migration
  def self.up
    create_table :bus_secured_actions, :force => true do |t|
      t.column :permitted_actions,     :string
    end
  end

  def self.down
    drop_table :bus_secured_actions
  end
end
