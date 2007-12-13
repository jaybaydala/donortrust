class AddCreatedByColumnToPendingProjects < ActiveRecord::Migration
  def self.up
    add_column :pending_projects, :created_by, :integer, :null => false
    execute('alter table pending_projects add foreign key (created_by) references bus_accounts (id)')
  end

  def self.down
    remove_column :pending_projects, :created_by
  end
end
