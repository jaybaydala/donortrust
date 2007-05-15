require 'active_record/fixtures'

class TaskStatusesRel001 < ActiveRecord::Migration
  def self.up
    create_table :task_statuses do |t|
      t.column :status, :string
      t.column :description, :text
    end
    
    if (ENV['RAILS_ENV'] = 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "task_statuses")
    end
  end
  
  def self.down
    drop_table :task_statuses
  end
end