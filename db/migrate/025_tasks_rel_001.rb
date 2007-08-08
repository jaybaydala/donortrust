require 'active_record/fixtures'

class TasksRel001 < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.column :milestone_id, :int, :null => false
      t.column :name, :string, :null => false, :limit =>50
      t.column :description, :text
      t.column :start_date, :date
      t.column :end_date, :date
      t.column :etc_date, :date
      t.column :version, :integer
    end
    
    if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "tasks")
    end
  end
  
  def self.down
    drop_table :tasks
  end
end