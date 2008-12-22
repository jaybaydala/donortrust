class CreatePledgeAccounts < ActiveRecord::Migration
  def self.up
    create_table :pledge_accounts do |t|
      t.decimal :balance, :precision => 12, :scale => 2
      t.references :campaign
      t.references :team
      t.references :user

      t.timestamps
    end
    add_index :pledge_accounts, :campaign_id
    add_index :pledge_accounts, :team_id
    add_index :pledge_accounts, :user_id
  end

  def self.down
    drop_table :pledge_accounts
  end
end
