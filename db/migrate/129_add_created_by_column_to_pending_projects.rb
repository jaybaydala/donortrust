class AddCreatedByColumnToPendingProjects < ActiveRecord::Migration
  def self.up
    add_column :pending_projects, :created_by, :integer, :null => false
  end

  def self.down
    remove_column :pending_projects, :created_by
  end
end
