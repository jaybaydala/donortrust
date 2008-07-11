class CreatePendingProjects < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      say "Creating the pending_projects table"
      create_table :pending_projects do |t|
      t.column :project_id, :integer, :null => false
      t.column :project_xml, :text, :null => false
      t.column :date_created, :date, :null => false
      t.column :rejected, :boolean, :default => false, :null => false
      t.column :rejection_reason, :text, :null => true
      t.column :rejected_by, :integer, :null => true
    end
      say "Adding indexes to the pending_projects table"
      execute('alter table pending_projects add foreign key (project_id) references projects (id)')
    end
  end

  def self.down
    drop_table :pending_projects
  end
end
