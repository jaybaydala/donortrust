require 'active_record/fixtures'

class MilestoneHistoriesRel001 < ActiveRecord::Migration
  def self.up
    create_table :milestone_histories do |t|
      t.column :milestone_id, :int
      t.column :created_at, :datetime
      t.column :reason, :text
      
      t.column :project_id, :int, :null => false
      t.column :milestone_category_id, :int, :null => false
      t.column :milestone_status_id, :int, :null => false
      t.column :measure_id, :int, :null => false
      t.column :description, :text
      t.column :target_date, :date
    end # milestone_histories
    
    if (ENV['RAILS_ENV'] = 'development')
    end
  end
  
  def self.down
    drop_table :milestone_histories
  end
end