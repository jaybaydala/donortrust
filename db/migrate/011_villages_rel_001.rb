require 'active_record/fixtures'

class VillagesRel001 < ActiveRecord::Migration
  def self.up
    create_table :villages do |t|
      t.column :village_name, :string, :null => false
      t.column :village_group_id, :int, :null => false
    end #villages
    
    if (ENV['RAILS_ENV'] = 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "villages")
    end
  end
  
  def self.down
    drop_table :villages
  end
end