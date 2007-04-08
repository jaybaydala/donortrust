require 'active_record/fixtures'

class DonortrustRel001 < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
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

    create_table :project_histories do |t|
      t.column :project_id, :integer, :null => false
      t.column :date, :datetime
      t.column :description, :text
      t.column :total_cost, :float
      t.column :dollars_spent, :float
      t.column :expected_completion_date, :datetime      
      t.column :start_date, :datetime
      t.column :end_date, :datetime
      t.column :user_id, :integer  
      t.column :project_status_id, :integer
      t.column :project_category_id, :integer
    end # project_histories

    create_table :milestones do |t|
      t.column :project_id, :int, :null => false
      t.column :milestone_category_id, :int, :null => false
      t.column :milestone_status_id, :int, :null => false
      t.column :measure_id, :int#, :null => false
      t.column :target_date, :date
      t.column :description, :text
    end # milestones

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

    create_table :contacts do |t|
      t.column :first_name, :string, :null => false
      t.column :last_name, :string, :null => false
      t.column :phone_number, :string
      t.column :fax_number, :string
      t.column :email_address, :string
      t.column :web_address, :string
      t.column :department, :string
      t.column :continent_id, :integer#, :null => false
      t.column :region_id, :integer#, :null => false
      t.column :city_id, :integer#, :null => false
      t.column :address_line_1, :string
      t.column :address_line_2, :string
      t.column :postal_code, :string
    end # contacts

    create_table :programs do |t|
      t.column :program_name, :string, :null => false
      t.column :contact_id, :string, :null => false
    end # programs

    create_table :continents do |t|
      t.column :continent_name, :string, :null => false
    end # continents
    
    create_table :countries do |t|
      t.column :country_name, :string, :null => false
      t.column :continent_id, :int, :null => false
    end # nations

    create_table :regions do |t|
      t.column :region_name, :string, :null => false
      t.column :country_id, :int, :null => false
    end # regions
    
    create_table :cities do |t|
      t.column :city_name, :string, :null => false
      t.column :region_id, :int, :null => false
    end # cities
    
    create_table :village_groups do |t|
      t.column :village_group_name, :string, :null => false
      t.column :region_id, :int, :null => false
    end # village_groups
    
    create_table :villages do |t|
      t.column :village_name, :string, :null => false
      t.column :village_group_id, :int, :null => false
    end # villages

    create_table :partner_types do |t|
      t.column :name, :string
    end # partner_types

    create_table :partner_statuses do |t|
      t.column :statusType, :string
      t.column :description, :string
    end # partner_statuses

    create_table :partners do |t|
      t.column :name, :string
      t.column :description, :string
      t.column :partner_type_id, :integer
      t.column :partner_status_id, :integer
    end # partners
    
    create_table :project_statuses do |t|
      t.column :status_type, :string, :null => false
      t.column :description, :text
    end # project_statuses    
    
    create_table :project_categories do |t|
      t.column :description, :text
    end # project_categories    

    create_table :milestone_categories do |t|
      t.column :category, :string
      t.column :description, :text
    end # milestone_categories

    create_table :milestone_statuses do |t|
      t.column :status, :string, :null => false
      t.column :description, :text
    end # milestone_statuses
    
    create_table :task_categories do |t|
      t.column :category, :string
      t.column :description, :text
    end

    create_table :measure_categories do |t|
      t.column :category, :string
      t.column :description, :text
    end

    create_table :measures do |t|
      t.column :measure_category_id, :int
      t.column :quantity, :int
      t.column :measure_date, :date
      t.column :user_id, :int
    end

    # Load some initial data
    # Rails 'convention' is to put the fixture files in test\fixtures
    # Do we really want to override that?
    # This is not a fixture for test. test/fixtures is ONLY for testing. i.e. development, test, production data are supposed to be all different.(tadatoshi)
    directory = File.join(File.dirname(__FILE__), "dev_data")
    Fixtures.create_fixtures(directory, "project_statuses")
    Fixtures.create_fixtures(directory, "project_categories")
    Fixtures.create_fixtures(directory, "milestone_statuses")
    Fixtures.create_fixtures(directory, "milestone_categories")
    Fixtures.create_fixtures(directory, "task_categories")
    Fixtures.create_fixtures(directory, "measure_categories")
    Fixtures.create_fixtures(directory, "continents")
    Fixtures.create_fixtures(directory, "countries")
    Fixtures.create_fixtures(directory, "regions")
    Fixtures.create_fixtures(directory, "cities")
    Fixtures.create_fixtures(directory, "village_groups")
    Fixtures.create_fixtures(directory, "villages")
    # Make sure to load all of the referenced lookup data before loading the
    # data that references it.
    Fixtures.create_fixtures(directory, "measures")
    Fixtures.create_fixtures(directory, "contacts")
    Fixtures.create_fixtures(directory, "programs")
    Fixtures.create_fixtures(directory, "projects")
    Fixtures.create_fixtures(directory, "milestones")
    #Fixtures.create_fixtures(directory, "tasks")
  end # self.up

  def self.down
    drop_table :projects
    drop_table :project_histories
    drop_table :milestones
    drop_table :milestone_histories
    drop_table :contacts
    drop_table :programs
    drop_table :continents
    drop_table :countries
    drop_table :regions
    drop_table :cities
    drop_table :village_groups
    drop_table :villages    
    drop_table :partner_types
    drop_table :partner_statuses
    drop_table :partners
    drop_table :project_statuses
    drop_table :project_categories
    drop_table :milestone_categories
    drop_table :milestone_statuses
    drop_table :task_categories
    drop_table :measure_categories
    drop_table :measures
  end # self.down
end #class DonorTrustRel001 