require 'active_record/fixtures'

class ProjectCategoriesRel001 < ActiveRecord::Migration
  def self.up
    create_table :project_categories do |t|
      t.column :description, :text
    end # project_categories    
    
    if (ENV['RAILS_ENV'] = 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "project_categories")
    end
  end
  
  def self.down
    drop_table :project_categories
  end
end