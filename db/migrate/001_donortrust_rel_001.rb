require 'active_record/fixtures'

class DonortrustRel001 < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.column :program_id, :integer
      t.column :category_id, :integer
      t.column :name, :string, :null => false
      t.column :description, :text
      t.column :cost, :float
      t.column :dollars_spent, :float
      t.column :expected_completion_date, :datetime
      t.column :start_date, :datetime
      t.column :end_date, :datetime
      t.column :status_id, :integer
      t.column :contact_id, :integer
      t.column :location_id, :integer
    end #:projects

    create_table :project_histories do |t|
      t.column :project_id, :integer, :null => false
      t.column :date, :datetime
      t.column :cost, :float
      t.column :dollars_spent, :float
      t.column :expected_completion_date, :datetime      
      t.column :start_date, :datetime
      t.column :end_date, :datetime
      t.column :user_id, :integer  
      t.column :status_id, :integer
    end #:project_histories

    create_table :milestone_histories do |t|
      t.column :milestone_id, :int
      t.column :created_at, :datetime
      t.column :reason, :text

      t.column :category, :string
      t.column :description, :text
      t.column :start, :date
      t.column :end, :date
      t.column :status_id, :int
    end #:milestone_histories

    create_table :milestones do |t|
      t.column :category, :string, :null => false
      t.column :description, :text, :null => false
      t.column :start, :date, :null => false
      t.column :end, :date, :null => false
      t.column :status_id, :int, :null => false
    end #:milestones

    create_table :statuses do |t|
      t.column :category, :string, :null => false
      t.column :description, :text, :null => false
    end #:statuses

    # Load some initial data
    # Rails 'convention' is to put the fixture files in test\fixtures
    # Do we really want to override that?
    # This is not a fixture for test. test/fixtures is ONLY for testing. i.e. development, test, production data are supposed to be all different.(tadatoshi)
    directory = File.join(File.dirname(__FILE__), "dev_data")
    Fixtures.create_fixtures(directory, "projects")
  end # self.up

  def self.down
    drop_table :projects
    drop_table :project_histories
    drop_table :milestones
    drop_table :milestone_histories
    drop_table :statuses
  end # self.down
end #class DonorTrustRel001 