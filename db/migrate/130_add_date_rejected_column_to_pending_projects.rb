class AddDateRejectedColumnToPendingProjects < ActiveRecord::Migration
  def self.up
    add_column :pending_projects, :date_rejected, :date, :null => true
  end

  def self.down
    remove_column :pending_projects, :date_rejected
  end
end
