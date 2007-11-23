class KeyMeasuresMillenniumGoalsRel001 < ActiveRecord::Migration
  def self.up
    create_table :key_measures_millennium_goals do |t|
      t.column :millennium_goal_id,     :integer
      t.column :key_measure_id,    :integer   
    end
  end
  def self.down
    drop_table :key_measures_millennium_goals
  end
end
