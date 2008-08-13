class AddShortDescToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :short_description, :string, :limit => 255
    add_column :project_versions, :short_description, :string, :limit => 255
  end

  def self.down
    remove_column :projects, :short_description
    remove_column :project_versions, :short_description
  end
end
