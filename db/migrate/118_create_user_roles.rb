class CreateUserRoles < ActiveRecord::Migration
  def self.up
      create_table :user_roles do |t|
      t.string :role_type
      t.integer :user_id
      t.integer :associated_entity_id
    end
  end

  def self.down
      drop_table :user_roles
  end
end
