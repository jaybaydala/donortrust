require 'active_record/fixtures'

class LoadProjectData < ActiveRecord::Migration

  def self.up
    down
    
    directory = File.join(File.dirname(__FILE__), "dev_data")
    Fixtures.create_fixtures(directory, "projects")
  end

  def self.down
    Project.delete_all
  end
  
end
