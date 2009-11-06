class AddGoalModifierToStatisticWidgets < ActiveRecord::Migration
  def self.up
    add_column :statistic_widgets, :goal_modifier, :string
  end

  def self.down
    remove_column :statistic_widgets, :goal_modifier
  end
end
