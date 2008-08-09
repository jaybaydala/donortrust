class RemoveBusUserTables < ActiveRecord::Migration
  def self.up
    drop_table :bus_secure_actions_bus_user_types
    drop_table :bus_secure_actions
    drop_table :bus_security_levels
    drop_table :bus_user_types
    drop_table :bus_users 
  end

  def self.down
    create_table :bus_users, :force => true do |t|
      t.column :login,                       :string
      t.column :email,                       :string
      t.column :crypted_password,            :string, :limit => 40
      t.column :salt,                        :string, :limit => 40
      t.column :created_at,                  :datetime
      t.column :updated_at,                  :datetime
      t.column :remember_token,              :string
      t.column :remember_token_expires_at,   :datetime
      t.column :bus_user_type_id,            :int   
    end
    
    if (true)
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "bus_users")
    end 
    
    create_table :bus_user_types, :force => true do |t|
      t.column :name,                      :string
    end     
    if (true)
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "bus_user_types") if File.exists? "#{directory}/bus_user_types.yml"
    end 

    create_table :bus_security_levels, :force => true do |t|
      t.column :controller,                     :string
    end

    if (true)
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "bus_security_levels")
    end

    create_table :bus_secure_actions, :force => true do |t|
      t.column :permitted_actions,     :string
      t.column :bus_security_level_id, :int
    end
    
    
    if (true)
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "bus_secure_actions")
    end

    create_table :bus_secure_actions_bus_user_types,:id => false, :force => true do |t|
      t.column :bus_secure_action_id,            :int
      t.column :bus_user_type_id,           :int
    end
    
    if (true)
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "bus_secure_actions_bus_user_types")
    end

  end
end
