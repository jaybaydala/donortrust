class Accounts < ActiveRecord::Migration
  def self.up
    create_table :accounts, :force => true do |t|
      t.column :first_name,   :string, :null => false
      t.column :last_name,    :string, :null => false
      t.column :address,      :text
      t.column :city,         :string
      t.column :state,        :string
      t.column :country,      :string
      t.column :email,        :string, :null => false
      t.column :crypted_password,     :string, :limit => 40
      t.column :salt,:string, :limit => 40
      t.column :last_logged_in,:datetime
    end    
    if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "accounts")
    end
  end

  def self.down
    drop_table :accounts
  end
end
