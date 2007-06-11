require 'active_record/fixtures'

class UrbanCentresRel001 < ActiveRecord::Migration
  def self.up
    create_table :urban_centres do |t|
      t.column :urban_centre_name, :string, :null => false
      t.column :region_id, :int, :null => false
      t.column :facebook_group_id, :int, :null => true
      t.column :blog_name, :string, :null => true
      t.column :blog_url, :string, :null => true
      t.column :rss_url, :string, :null => true
      t.column :population, :int, :null => true
      t.column :village_plan, :text, :null => true
      t.column :facebook_group_id, :string
      
    end #urban_centres
    
    if (ENV['RAILS_ENV'] = 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "urban_centres")
    end
  end
  
  def self.down
    drop_table :urban_centres
  end
end