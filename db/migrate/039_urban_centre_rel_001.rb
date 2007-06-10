class UrbanCentreRel001 < ActiveRecord::Migration
  def self.up
    create_table :urban_centres, :force => true do |t|
    t.column :urban_centre_name, :string, :null => false
    t.column :region_id, :int, :null => false
    t.column :blog_name, :string
    t.column :blog_url, :string
    t.column :rss_url, :string 
    t.column :population, :int
    t.column :village_plan, :text
    t.column :facebook_group_id, :int
    end
    
     if (ENV['RAILS_ENV'] = 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "urban_centres")
    end
  end

  def self.down
    drop_table :urban_centres
  end
end
