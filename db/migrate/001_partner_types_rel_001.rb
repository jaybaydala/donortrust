require 'active_record/fixtures'

class PartnerTypesRel001 < ActiveRecord::Migration
  def self.up
    create_table :partner_types, :force => true do |t|
      t.column :name, :string, :limit => 50, :null => false
      t.column :description, :text, :limit => 500, :null => false
    end #partner_types
    
    
    if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "partner_types")
    end
  end
  
  def self.down
    drop_table :partner_types
  end
end