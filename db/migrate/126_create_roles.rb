class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :title
    end
    create_table :administrations do |t|
      t.integer "role_id"
      t.integer "user_id"
      t.references :administrable, :polymorphic => true
    end

      directory = File.join(File.dirname(__FILE__), "dev_data")
      Fixtures.create_fixtures(directory, "roles") if File.exists? "#{directory}/roles.yml"
    if (ENV['RAILS_ENV'] == 'development')
      Fixtures.create_fixtures(directory, "administrations") if File.exists? "#{directory}/administrations.yml"
    end
  end

  def self.down
      drop_table :roles
      drop_table :administrations
  end
end
