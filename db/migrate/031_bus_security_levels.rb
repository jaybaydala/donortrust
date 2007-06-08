class BusSecurityLevels < ActiveRecord::Migration
  def self.up
    
    create_table :bus_security_levels, :force => true do |t|
      t.column :level,                     :int
    end

    if (ENV['RAILS_ENV'] = 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "bus_security_levels")
    end
  end

  def self.down
    drop_table :bus_security_levels
  end
end
