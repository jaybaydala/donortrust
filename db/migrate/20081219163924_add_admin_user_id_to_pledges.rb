class AddAdminUserIdToPledges < ActiveRecord::Migration
  def self.up
    add_column :pledges, :admin_user_id, :integer
  end

  def self.down
    remove_column :pledges, :admin_user_id
  end
end
