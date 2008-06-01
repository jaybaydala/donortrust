class AddTimestampsToGroupWallMessages < ActiveRecord::Migration
  def self.up
    add_column :group_wall_messages, :created_at, :datetime
    add_column :group_wall_messages, :updated_at, :datetime
  end

  def self.down
    remove_column :group_wall_messages, :created_at
    remove_column :group_wall_messages, :updated_at
  end
end
