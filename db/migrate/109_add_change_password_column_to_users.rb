class AddChangePasswordColumnToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :change_password, :boolean
    add_column :user_versions, :change_password, :boolean
  end

  def self.down
    remove_column :users, :change_password
    remove_column :user_versions, :change_password
  end
end
