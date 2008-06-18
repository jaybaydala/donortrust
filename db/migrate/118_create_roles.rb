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
  end

  def self.down
      drop_table :roles
      drop_table :administrations
  end
end
