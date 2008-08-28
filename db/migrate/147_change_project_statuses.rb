class ChangeProjectStatuses < ActiveRecord::Migration
  def self.up
    directory = File.join(File.dirname(__FILE__), "dev_data")
    Fixtures.create_fixtures(directory, "project_statuses") if File.exists? "#{directory}/project_statuses.yml"
  end

  def self.down
  end
end
