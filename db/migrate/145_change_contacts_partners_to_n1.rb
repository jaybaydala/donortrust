class ChangeContactsPartnersToN1 < ActiveRecord::Migration
  def self.up
    add_column :contacts, :partner_id, :integer
    
    Contact.find(:all).each do |c|
      partners = Partner.find_by_sql "SELECT partner_id FROM contacts_partners WHERE contact_id = #{c.id}"
      c.partner_id = partners[0].partner_id if partners.size > 0
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
