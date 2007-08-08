class GroupsProjectsRel001 < ActiveRecord::Migration
  def self.up
    create_table :groups_projects do |t|
      t.column :group_id,         :int
      t.column :project_id,       :int
    end    
    if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "groups_projects") if File.exists? "#{directory}/groups_projects.yml"
    end
  end

  def self.down
    drop_table :groups_projects
  end
end
