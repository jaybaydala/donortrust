require 'active_record/fixtures'

class PartnerVersionsRel001 < ActiveRecord::Migration
  def self.up
    #    if (ENV['RAILS_ENV'] == 'development')
    ##      directory = File.join(File.dirname(__FILE__), "dev_data")
    ##      Fixtures.create_fixtures(directory, "partner_histories")
    #    end
    
    Partner.create_versioned_table
  end
  
  def self.down
    #    drop_table :partner_histories  
    Partner.drop_versioned_table
  end
end
