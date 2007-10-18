require 'active_record/fixtures'
class ProjectsRel001 < ActiveRecord::Migration
  def self.up
    create_table :projects, :force => true do |t|
      t.column :program_id, :integer
      t.column :name, :string, :null => false
      t.column :description, :text
      t.column :total_cost, :decimal, :precision => 12, :scale => 2, :default => 0
      t.column :dollars_spent, :decimal, :precision => 12, :scale => 2, :default => 0
      t.column :expected_completion_date, :date
      t.column :blog_url, :string
      t.column :rss_url, :string
      t.column :actual_start_date, :date
      t.column :actual_end_date, :date
      t.column :target_start_date, :date
      t.column :target_end_date, :date
      t.column :project_status_id, :integer
      t.column :contact_id, :integer
      t.column :place_id, :integer
      t.column :partner_id, :integer
      t.column :frequency_type_id, :integer
      t.column :lives_affected, :integer
      t.column :featured, :boolean
      t.column :public, :boolean
      t.column :note, :text
      t.column :intended_outcome, :text
      t.column :meas_eval_plan, :text
      t.column :project_in_community, :text
      t.column :other_projects, :text   
      t.column :deleted_at, :datetime
      t.column :version, :integer
    end # projects
    
    Project.create_versioned_table
    
    if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "projects")
    end
  end
  
  def self.down
    drop_table :projects
    Project.drop_versioned_table
  end
end