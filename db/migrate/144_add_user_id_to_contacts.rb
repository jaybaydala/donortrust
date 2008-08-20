class AddUserIdToContacts < ActiveRecord::Migration
  def self.up
    add_column :contacts, :user_id, :integer
  end

  def self.down
    remove_column :contacts, :user_id
  end
end
