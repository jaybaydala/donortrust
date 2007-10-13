require 'active_record/fixtures'
class TasksRel001 < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.column :milestone_id, :int, :null => false
      t.column :name, :string, :null => false, :limit =>50
      t.column :description, :text
      t.column :target_start_date, :date
      t.column :target_end_date, :date
      t.column :actual_start_date, :date
      t.column :actual_end_date, :date
      t.column :deleted_at, :datetime
      t.column :version, :integer
    end
    
    Task.create_versioned_table
    
    if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "tasks")
    end
  end
  
  def self.down
    drop_table :tasks
    Task.drop_versioned_table
  end
end