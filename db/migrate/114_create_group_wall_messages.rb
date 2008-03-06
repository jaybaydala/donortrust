class CreateGroupWallMessages < ActiveRecord::Migration
  def self.up
    create_table "group_wall_messages" do |t|
      t.column :message, :text
      t.column :group_id, :integer
      t.column :user_id, :integer
    end
  end

  def self.down
    drop_table "group_wall_messages"
  end
end
