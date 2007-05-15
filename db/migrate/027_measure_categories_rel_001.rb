require 'active_record/fixtures'

class MeasureCategoriesRel001 < ActiveRecord::Migration
  def self.up
    create_table :measure_categories do |t|
      t.column :category, :string
      t.column :description, :text
    end
    
    if (ENV['RAILS_ENV'] = 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "measure_categories")
    end
  end
  
  def self.down
    drop_table :measure_categories
  end
end