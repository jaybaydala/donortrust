class TasksAddPercentComplete < ActiveRecord::Migration
  def self.up
  add_column :tasks, :percent_complete, :integer
  add_column :task_versions, :percent_complete, :integer
    
  end

  def self.down
   remove_column :tasks, :percent_complete
   remove_column :task_versions, :percent_complete
  end
end

