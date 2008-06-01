class UserTransactionsRel001 < ActiveRecord::Migration
  def self.up
    create_table "user_transactions", :force => true do |t|
      t.column :user_id,        :int
      t.column :tx_id,          :int
      t.column :tx_type,        :string
      t.column :created_at,     :datetime
      t.column :updated_at,     :datetime
    end
    add_index :user_transactions, :user_id

    if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "user_transactions") if File.exists? "#{directory}/user_transactions.yml"
    end
  end

  def self.down
    drop_table "user_transactions"
  end
end
