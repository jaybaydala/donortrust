require 'active_record/fixtures'

class CitiesRel001 < ActiveRecord::Migration
  def self.up
    create_table :cities do |t|
      t.column :city_name, :string, :null => false
      t.column :region_id, :int, :null => false
    end # cities
    
    if (ENV['RAILS_ENV'] = 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "cities")
    end
  end
  
  def self.down
    drop_table :cities
  end
end