class AddTimestampsToSubscriptions < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :created_at, :datetime
    add_column :subscriptions, :updated_at, :datetime
  end

  def self.down
    remove_column :subscriptions, :updated_at
    remove_column :subscriptions, :created_at
  end
end
