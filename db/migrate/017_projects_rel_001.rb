require 'active_record/fixtures'

class ProjectsRel001 < ActiveRecord::Migration
  def self.up
    create_table :projects, :force => true do |t|
      t.column :program_id, :integer
      t.column :project_category_id, :integer
      t.column :name, :string, :null => false
      t.column :description, :text
      t.column :total_cost, :float
      t.column :dollars_spent, :float
      t.column :expected_completion_date, :datetime
      t.column :start_date, :datetime
      t.column :end_date, :datetime
      t.column :project_status_id, :integer
      t.column :contact_id, :integer
      t.column :village_group_id, :integer
      t.column :partner_id, :integer
    end # projects
    
    if (ENV['RAILS_ENV'] = 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "projects")
    end
  end
  
  def self.down
    drop_table :projects
  end
end