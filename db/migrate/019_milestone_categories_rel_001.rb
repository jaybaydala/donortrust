require 'active_record/fixtures'

class MilestoneCategoriesRel001 < ActiveRecord::Migration
  def self.up
    create_table :milestone_categories do |t|
      t.column :category, :string
      t.column :description, :text
    end # milestone_categories
    
    if (ENV['RAILS_ENV'] = 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "milestone_categories")
    end
  end
  
  def self.down
    drop_table :milestone_categories
  end
end