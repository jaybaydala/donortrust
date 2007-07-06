require 'active_record/fixtures'

class ProjectStatusesRel001 < ActiveRecord::Migration
  def self.up
    create_table :project_statuses do |t|
      t.column :name, :string, :null => false
      t.column :description, :text
    end # project_statuses    
    
    if (ENV['RAILS_ENV'] = 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "project_statuses")
    end
  end
  
  def self.down
    drop_table :project_statuses
  end
end