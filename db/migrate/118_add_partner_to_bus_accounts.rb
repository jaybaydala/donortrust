class AddPartnerToBusAccounts < ActiveRecord::Migration
  def self.up
      add_column :bus_accounts, :partner_id, :integer, :null => true
      execute('alter table bus_accounts add foreign key (partner_id) references partners (id)')
  end

  def self.down
    remove_column :bus_accounts, :partner_id
  end
end
