class AddGoalToCampaigns < ActiveRecord::Migration
  def self.up
    add_column :campaigns, :goal, :decimal, :precision => 12, :scale => 2
  end

  def self.down
    remove_column :campaigns, :goal
  end
end
