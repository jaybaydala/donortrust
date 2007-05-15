require 'active_record/fixtures'

class PartnersRel001 < ActiveRecord::Migration
  def self.up
    create_table :partners do |t|
      t.column :name, :string
      t.column :description, :string
      t.column :partner_type_id, :integer
      t.column :partner_status_id, :integer
    end #partners    
    
    if (ENV['RAILS_ENV'] = 'development')
    end
  end
  
  def self.down
    drop_table :partners
  end
end