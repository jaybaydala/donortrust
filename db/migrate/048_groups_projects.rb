class GroupsProjects < ActiveRecord::Migration
  def self.up
    create_table :groups_projects, :id => false do |t|
      t.column :group_id,         :int
      t.column :project_id,       :int
    end    
    if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "groups_projects")
    end
  end

  def self.down
    drop_table :groups_projects
  end
end
