class AddIsNewColumnToPendingProjects < ActiveRecord::Migration
  def self.up
    add_column :pending_projects, :is_new, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :pending_projects, :is_new
  end
end
