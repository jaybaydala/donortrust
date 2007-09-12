require 'active_record/fixtures'
class UsersRel001 < ActiveRecord::Migration
  def self.up
      create_table "users", :force => true do |t|
      t.column :login,                     :string
      t.column :first_name,                :string
      t.column :last_name,                 :string
      t.column :display_name,              :string
      t.column :address,                   :string
      t.column :city,                      :string
      t.column :province,                  :string
      t.column :postal_code,               :string
      t.column :country,                   :string
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
      t.column :remember_token,            :string
      t.column :remember_token_expires_at, :datetime
      t.column :activation_code,           :string, :limit => 40
      t.column :activated_at,              :datetime
      t.column :last_logged_in_at,         :datetime
      #t.column :active,                    :boolean, :default => true
      t.column :deleted_at, :datetime
      t.column :version, :integer
    end
    
    User.create_versioned_table
    
    if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "users") if File.exists? "#{directory}/users.yml"
    end
  end

  def self.down
    drop_table "users"
    User.drop_versioned_table
  end
end
