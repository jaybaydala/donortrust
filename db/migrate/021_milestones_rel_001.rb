require 'active_record/fixtures'
class MilestonesRel001 < ActiveRecord::Migration
  def self.up
    create_table :milestones do |t|
      t.column :project_id, :int, :null => false
      t.column :name, :string, :limit => 50
      t.column :description, :text
      t.column :target_start_date, :date
      t.column :target_end_date, :date
      t.column :actual_start_date, :date
      t.column :actual_end_date, :date
      t.column :milestone_status_id, :int, :null => false
      t.column :deleted_at, :datetime
      t.column :version, :integer
    end # milestones
    
    Milestone.create_versioned_table
 
    if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "milestones")
    end
  end

  def self.down
    drop_table :milestones 
    Milestone.drop_versioned_table
  end
end