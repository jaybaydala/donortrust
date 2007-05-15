require 'active_record/fixtures'

class ContinentsRel001 < ActiveRecord::Migration
  def self.up
    create_table :continents do |t|
      t.column :continent_name, :string, :null => false
    end # continents
    
    if (ENV['RAILS_ENV'] = 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "continents")
    end
  end
  
  def self.down
    drop_table :continents
  end
end