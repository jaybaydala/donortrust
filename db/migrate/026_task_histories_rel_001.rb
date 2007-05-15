require 'active_record/fixtures'

class TaskHistoriesRel001 < ActiveRecord::Migration
  def self.up
    create_table :task_histories do |t|
      t.column :task_id, :int, :null => false
      t.column :created_at, :datetime, :null => false
      t.column :milestone_id, :int, :null => false
      t.column :title, :string, :null => false
      t.column :task_category_id, :int, :null => false
      t.column :task_status_id, :int, :null => false
      t.column :description, :text
      t.column :start_date, :date
      t.column :end_date, :date
      t.column :etc_date, :date
    end
    
    if (ENV['RAILS_ENV'] = 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "task_histories")
    end
  end
  
  def self.down
    drop_table :task_histories
  end
end