class AddLocationBooleansToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :ca, :boolean, :default => true
    add_column :projects, :us, :boolean, :default => true
    add_column :project_versions, :ca, :boolean
    add_column :project_versions, :us, :boolean
  end

  def self.down
    remove_column :projects, :us
    remove_column :projects, :ca
    remove_column :project_versions, :us
    remove_column :project_versions, :ca
  end
end
