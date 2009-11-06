class AddActiveToStatisticWidgets < ActiveRecord::Migration
  def self.up
    add_column :statistic_widgets, :active, :boolean, :default => false
  end

  def self.down
    remove_column :statistic_widgets, :active
  end
end
