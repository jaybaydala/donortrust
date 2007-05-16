require 'active_record/fixtures'
require 'migration_constants'

class PartnerTypesRel001 < ActiveRecord::Migration
  def self.up
    create_table :partner_types, :force => true do |t|
      t.column :name, :string
    end #partner_types
    
    if (ENV['RAILS_ENV'] == 'development')
      
      Fixtures.create_fixtures(directory, "partner_types")
    end
  end
  
  def self.down
    drop_table :partner_types
  end
end