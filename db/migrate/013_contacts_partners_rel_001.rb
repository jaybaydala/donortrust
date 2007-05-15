require 'active_record/fixtures'

class Base_Rel001 < ActiveRecord::Migration
  def self.up
    create_table :contacts_partners do |t|
      t.column :contact_id, :integer, :null => false
      t.column :partner_id, :integer, :null => false
    end #contacts_partners
    
    if (ENV['RAILS_ENV'] = 'development')
    end
  end
  
  def self.down
    drop_table :contacts_partners
  end
end