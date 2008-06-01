class BusSecurityLevels < ActiveRecord::Migration
  def self.up
    
    create_table :bus_security_levels, :force => true do |t|
      t.column :controller,                     :string
    end

    if (true)
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "bus_security_levels")
    end
    
  end

  def self.down
    drop_table :bus_security_levels
  end
end
