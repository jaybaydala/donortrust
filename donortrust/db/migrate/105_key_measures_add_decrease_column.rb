class KeyMeasuresAddDecreaseColumn < ActiveRecord::Migration
  def self.up
    add_column :key_measures, :decrease_target, :boolean, :default =>false, :null => false
  end

  def self.down
    remove_column :key_measures, :decrease_target
  end
end
