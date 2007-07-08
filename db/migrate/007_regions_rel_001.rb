require 'active_record/fixtures'

class RegionsRel001 < ActiveRecord::Migration
  def self.up
    create_table :regions do |t|
      t.column :region_name, :string, :null => false
      t.column :country_id, :int, :null => false
      t.column :region_type_id, :int, :null =>false
    end #regions
    
    if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "regions")
    end
  end
  
  def self.down
    drop_table :regions
  end
end