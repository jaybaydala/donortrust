class AddGroupToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :group, :boolean, :default => false
    add_column :user_versions, :group, :boolean, :default => false
  end

  def self.down
    remove_column :users, :group
    remove_column :user_versions, :group
  end
end
