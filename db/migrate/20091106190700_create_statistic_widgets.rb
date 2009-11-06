class CreateStatisticWidgets < ActiveRecord::Migration
  def self.up
    create_table :statistic_widgets do |t|
      t.string :title
      t.string :progress
      t.string :goal
      t.string :goal_name
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :statistic_widgets
  end
end
