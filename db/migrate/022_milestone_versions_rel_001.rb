require 'active_record/fixtures'

class MilestoneVersionsRel001 < ActiveRecord::Migration
  def self.up
    Milestone.create_versioned_table

    #    if (ENV['RAILS_ENV'] == 'development')
    ##      directory = File.join(File.dirname(__FILE__), "dev_data")
    ##      Fixtures.create_fixtures(directory, "milestone_versions")
    #    end
  end

  def self.down
    Milestone.drop_versioned_table
  end
end
