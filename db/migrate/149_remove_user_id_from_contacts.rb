class RemoveUserIdFromContacts < ActiveRecord::Migration
  def self.up
    remove_column :contacts, :user_id
  end

  def self.down
    add_column :contacts, :user_id, :integer
  end
end
