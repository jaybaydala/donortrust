class AddSubmissionDateToPendingProjects < ActiveRecord::Migration
  def self.up
    add_column :pending_projects, :submitted_at, :datetime
  end

  def self.down
    remove_column :pending_projects, :submitted_at
  end
end
