class AddUserIdToLikes < ActiveRecord::Migration
  def self.up
    add_column :likes, :user_id, :integer
  end

  def self.down
    remove_column :likes, :user_id
  end
end
