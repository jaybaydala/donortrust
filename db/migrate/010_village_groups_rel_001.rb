require 'active_record/fixtures'

class VillageGroupsRel001 < ActiveRecord::Migration
  def self.up
    create_table :village_groups do |t|
      t.column :village_group_name, :string, :null => false
      t.column :region_id, :int, :null => false
    end #village_groups
    
    if (ENV['RAILS_ENV'] = 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "village_groups")
    end
  end
  
  def self.down
    drop_table :village_groups
  end
end