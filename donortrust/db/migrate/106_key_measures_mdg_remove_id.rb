class KeyMeasuresMdgRemoveId < ActiveRecord::Migration
  def self.up
    remove_column :key_measures_millennium_goals, :id
  end

  def self.down
    add_column :key_measures_millennium_goals, :id, :integer, :null => false
  end
end
