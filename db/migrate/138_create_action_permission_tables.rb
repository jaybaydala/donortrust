class CreateActionPermissionTables < ActiveRecord::Migration
  def self.up

    create_table :authorized_controllers, :force => true do |t|
      t.string :name
    end

    create_table :authorized_actions, :force => true do |t|
      t.string :name
      t.integer :authorized_controller_id
    end

    create_table :permissions, :force => true do |t|
      t.integer :authorized_action_id
      t.integer :role_id
    end

    #if (ENV['RAILS_ENV'] == 'development')
      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "authorized_controllers") if File.exists? "#{directory}/authorized_controllers.yml"
      Fixtures.create_fixtures(directory, "authorized_actions") if File.exists? "#{directory}/authorized_actions.yml"
      Fixtures.create_fixtures(directory, "permissions") if File.exists? "#{directory}/permissions.yml"
    #end
  end

  def self.down
    drop_table :authorized_controllers
    drop_table :authorized_actions
    drop_table :permissions
  end
end
