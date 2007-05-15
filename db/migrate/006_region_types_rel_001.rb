require 'active_record/fixtures'

class RegionTypesRel001 < ActiveRecord::Migration
  def self.up
    create_table :region_types do |t|
      t.column :region_type_name, :string, :null => false
    end # region_types
    
    if (ENV['RAILS_ENV'] = 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "region_types")
    end
  end
  
  def self.down
    drop_table :region_types
  end
end