require 'active_record/fixtures'

class MilestonesRel001 < ActiveRecord::Migration
  def self.up
    create_table :milestones do |t|
      t.column :project_id, :int, :null => false
      t.column :name, :string, :limit => 50
      t.column :description, :text
      t.column :target_date, :date
      t.column :milestone_status_id, :int, :null => false
      t.column :version, :integer
    end # milestones
 
    if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "milestones")
    end
  end

  def self.down
    drop_table :milestones 
  end
end