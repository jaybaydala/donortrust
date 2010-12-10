class AddSuperuserToUserVersions < ActiveRecord::Migration
  def self.up
    add_column :user_versions, :superuser, :boolean
  end

  def self.down
    remove_column :user_versions, :superuser
  end
end
