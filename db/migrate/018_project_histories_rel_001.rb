require 'active_record/fixtures'

class ProjectHistoriesRel001 < ActiveRecord::Migration
  def self.up
    create_table :project_histories do |t|
      t.column :project_id, :integer, :null => false
      t.column :date, :date
      t.column :description, :text
      t.column :total_cost, :float
      t.column :dollars_raised, :float
      t.column :dollars_spent, :float
      t.column :expected_completion_date, :date   
      t.column :start_date, :date
      t.column :end_date, :date
      t.column :user_id, :integer  
      t.column :project_status_id, :integer
      t.column :project_category_id, :integer     
      t.column :bus_user_id, :integer

    end # project_histories
    
    if (ENV['RAILS_ENV'] = 'development')
    end
  end
  
  def self.down
    drop_table :project_histories
  end
end