require 'active_record/fixtures'

class ContactsPartnersRel001 < ActiveRecord::Migration
  def self.up
    create_table :contacts_partners do |t|
      t.column :contact_id, :integer, :null => false
      t.column :partner_id, :integer, :null => false
    end #contacts_partners
  end
  
  def self.down
    drop_table :contacts_partners
  end
end