require 'active_record/fixtures'

class CountriesRel001 < ActiveRecord::Migration
  def self.up
    
    create_table :countries do |t|
      t.column :name, :string, :null => false
      t.column :continent_id, :int, :null => false
      t.column :html_data, :text, :null => true 
    end #countries
    
    if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "countries")
    end
    
  end
  
  def self.down
    drop_table :countries
  end
end