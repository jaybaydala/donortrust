class AddShortDescToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :short_description, :string, :limit => 255
  end

  def self.down
    remove_column :projects, :short_description
  end
end
