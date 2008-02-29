class CreateGroupWalls < ActiveRecord::Migration
  def self.up
    create_table "group_walls" do |t|
      t.column :message, :text
      t.column :group_id, :integer
      t.column :user_id, :integer
    end
  end

  def self.down
    drop_table "group_walls"
  end
end
