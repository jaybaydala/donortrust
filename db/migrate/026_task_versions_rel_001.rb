require 'active_record/fixtures'

class TaskVersionsRel001 < ActiveRecord::Migration
  def self.up
    Task.create_versioned_table

    #    if (ENV['RAILS_ENV'] == 'development')
    ##      directory = File.join(File.dirname(__FILE__), "dev_data")
    ##      Fixtures.create_fixtures(directory, "task_versions")
    #    end
  end

  def self.down
    Task.drop_versioned_table
  end
end
