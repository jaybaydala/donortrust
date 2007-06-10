class BusSecurityLevels < ActiveRecord::Migration
  def self.up
    
    create_table :bus_security_levels, :force => true do |t|
      t.column :controller,                     :string
    end

    
  end

  def self.down
    drop_table :bus_security_levels
  end
end
