class BusUserTypes < ActiveRecord::Migration
  def self.up
    create_table :bus_user_types, :force => true do |t|
      t.column :name,                      :string
    end     
    if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "bus_user_types") if File.exists? "#{directory}/bus_user_types.yml"
    end    
  end

  def self.down
    drop_table :bus_user_types
  end
end
