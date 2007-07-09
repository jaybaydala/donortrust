class BusSecureActions < ActiveRecord::Migration
  def self.up
    create_table :bus_secure_actions, :force => true do |t|
      t.column :permitted_actions,     :string
      t.column :bus_security_level_id, :int
    end
    
    
    if (ENV['RAILS_ENV'] = 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "bus_secure_actions")
    end
  end

  def self.down
    drop_table :bus_secure_actions
  end
end
