class MillenniumGoalsCausesRel001 < ActiveRecord::Migration
  def self.up
    create_table :causes_millennium_goals,  :id => false do |t|
      t.column   :cause_id,  :integer
      t.column :millennium_goal_id,    :integer   
    end
  end
  def self.down
    drop_table :causes_millennium_goals
  end
end
