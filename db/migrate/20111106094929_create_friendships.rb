class CreateFriendships < ActiveRecord::Migration
  def self.up
    create_table :friendships do |t|
      t.integer :user_id
      t.integer :friend_id
      t.boolean :status, :default => false
      t.datetime :accepted_at

      t.timestamps
    end
  end

  def self.down
    drop_table :friendships
  end
end
