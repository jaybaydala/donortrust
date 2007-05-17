require 'active_record/fixtures'

class PartnerStatusesRel001 < ActiveRecord::Migration
  def self.up
    
    create_table :partner_statuses, :force => true do |t|
      t.column :statusType, :string, :null => false, :limit => 25
      t.column :description, :string, :limit => 250
    end #partner_statuses
    
    if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "partner_statuses")
    end
  end
  
  def self.down
    drop_table :partner_statuses
  end
end