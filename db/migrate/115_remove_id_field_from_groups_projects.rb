class RemoveIdFieldFromGroupsProjects < ActiveRecord::Migration
  def self.up
    remove_column :groups_projects, :id
  end

  def self.down
    add_column :groups_projects, :id, :integer, :null => :false
    execute "ALTER TABLE `groups_projects` CHANGE `id` `id` int(11) auto_increment PRIMARY KEY"
  end
end
