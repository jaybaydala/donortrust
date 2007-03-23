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
    end #:projects

    create_table :project_histories do |t|
      t.column :project_id, :integer, :null => false
      t.column :date, :datetime
      t.column :description, :text
      t.column :total_cost, :float
      t.column :dollars_spent, :float
      t.column :expected_completion_date, :datetime      
      t.column :start_date, :datetime
      t.column :end_date, :datetime
      t.column :contact_id, :integer  
      t.column :project_status_id, :integer
      t.column :project_category_id, :integer
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

    create_table :contacts do |t|
      t.column :first_name, :string, :null => false
      t.column :last_name, :string, :null => false
      t.column :phone_number, :string
      t.column :fax_number, :string
      t.column :email_address, :string
      t.column :web_address, :string
      t.column :department, :string
      t.column :continent_id, :integer, :null => false
      t.column :region_id, :integer, :null => false
      t.column :city_id, :integer, :null => false
      t.column :address_line_1, :string
      t.column :address_line_2, :string
      t.column :postal_code, :string
    end #:contacts

 create_table :continents do |t|
        t.column :continent_name, :string, :null => false
    end #:continents
    
     create_table :nations do |t|
        t.column :nation_name, :string, :null => false
        t.column :continent_id, :int, :null => false
     end #nations


    create_table :regions do |t|
      t.column :region_name, :string, :null => false
      t.column :nation_id, :int, :null => false
    end #regions
    
    create_table :cities do |t|
      t.column :city_name, :string, :null => false
      t.column :region_id, :int, :null => false
    end # cities
    
    create_table :village_groups do |t|
      t.column :village_group_name, :string, :null => false
      t.column :region_id, :int, :null => false
    end #village_groups
    
    create_table :villages do |t|
      t.column :village_name, :string, :null => false
      t.column :village_group_id, :int, :null => false
    end #villages

    create_table :partner_types do |t|
      t.column :name, :string
    end #partner_types

    create_table :partner_statuses do |t|
      t.column :statusType, :string
      t.column :description, :string
    end #partner_statuses

    create_table :partners do |t|
      t.column :name, :string
      t.column :description, :string
      t.column :partner_type_id, :integer
      t.column :partner_status_id, :integer
    end #partners
    
    create_table :project_statuses do |t|
      t.column :status_type, :string, :null => false
      t.column :description, :text
    end #:project_statuses    
    
    # Load some initial data
    # Rails 'convention' is to put the fixture files in test\fixtures
    # Do we really want to override that?
    # This is not a fixture for test. test/fixtures is ONLY for testing. i.e. development, test, production data are supposed to be all different.(tadatoshi)
    directory = File.join(File.dirname(__FILE__), "dev_data")
    Fixtures.create_fixtures(directory, "project_statuses")
  end # self.up

  def self.down
    drop_table :projects
    drop_table :project_histories
    drop_table :milestones
    drop_table :milestone_histories
    drop_table :statuses
    drop_table :contacts
    drop_table :continents
    drop_table :nations
    drop_table :regions
    drop_table :cities
    drop_table :village_groups
    drop_table :villages    
    drop_table :partner_types
    drop_table :partner_statuses
    drop_table :partners
    drop_table :project_statuses
  end # self.down
end #class DonorTrustRel001 