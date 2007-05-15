require 'active_record/fixtures'

class PartnerHistoriesRel001 < ActiveRecord::Migration
  def self.up
    create_table :partner_histories do |t|
      t.column :partner_id, :integer
      t.column :name, :string
      t.column :description, :text
      t.column :partner_type_id, :integer
      t.column :partner_status_id, :integer
    end #partner_histories
    
    if (ENV['RAILS_ENV'] = 'development')
    end
  end
  
  def self.down
    drop_table :partner_histories    
  end
end