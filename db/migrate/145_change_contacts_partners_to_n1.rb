class ChangeContactsPartnersToN1 < ActiveRecord::Migration
  def self.up
    add_column :contacts, :partner_id, :integer
    
    Contact.find(:all).each do |c|
      c.partner_id = c.partners[0].id if c.partners.size > 0
      c.save
    end
    
    drop_table :contacts_partners
  end

  def self.down
    remove_column :contacts, :partner_id
    
    create_table :contacts_partners do |t|
      t.column :contact_id, :integer, :null => false
      t.column :partner_id, :integer, :null => false
    end
  end
end
