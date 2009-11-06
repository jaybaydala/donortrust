class AddBioAndStaffToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :bio, :text
    add_column :users, :staff, :boolean
    add_column :user_versions, :bio, :text
    add_column :user_versions, :staff, :boolean
  end

  def self.down
    remove_column :user_versions, :staff
    remove_column :user_versions, :bio
    remove_column :users, :staff
    remove_column :users, :bio
  end
end
