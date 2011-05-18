class AddBirthdayToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :birthday, :date
    add_column :user_versions, :birthday, :date
  end

  def self.down
    remove_column :users, :birthday
    remove_column :user_versions, :birthday
  end
end
