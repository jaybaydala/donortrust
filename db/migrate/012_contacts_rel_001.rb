require 'active_record/fixtures'

class ContactsRel001 < ActiveRecord::Migration
  def self.up
    create_table :contacts do |t|
      t.column :first_name, :string, :limit => 50, :null => false
      t.column :last_name, :string, :limit =>50, :null => false
      t.column :phone_number, :string, :limit =>15
      t.column :fax_number, :string,   :limit =>15 
      t.column :email_address, :string, :limit => 50
      t.column :web_address, :string, :limit =>50
      t.column :department, :string, :limit =>50
      t.column :country_id, :integer
      t.column :region_id, :integer#, :null => false
      t.column :urban_centre_id, :integer#, :null => false
      t.column :address_line_1, :string
      t.column :address_line_2, :string
      t.column :postal_code, :string, :limit => 12
    end # contacts
    
    
    if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "contacts")
    end
  end
  
  def self.down
    drop_table :contacts
  end
end