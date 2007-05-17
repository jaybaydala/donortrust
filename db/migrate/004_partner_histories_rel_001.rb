require 'active_record/fixtures'

class PartnerHistoriesRel001 < ActiveRecord::Migration
  def self.up
    create_table :partner_histories do |t|
      t.column :partner_id, :integer
      t.column :name, :string, :limit => 50
      t.column :description, :string, :limit => 1000
      t.column :partner_type_id, :integer
      t.column :partner_status_id, :integer
      t.column :created_on, :datetime
    end #partner_histories
    
    if (ENV['RAILS_ENV'] == 'development')
#      directory = File.join(File.dirname(__FILE__), "dev_data")
#      Fixtures.create_fixtures(directory, "partner_histories")
    end
  end
  
  def self.down
    drop_table :partner_histories    
  end
end