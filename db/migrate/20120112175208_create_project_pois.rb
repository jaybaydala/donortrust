class CreateProjectPois < ActiveRecord::Migration
  def self.up
    create_table :project_pois do |t|
      t.integer :project_id
      t.integer :user_id
      t.string :name
      t.string :email
      t.boolean :send_updates, :default => true
      t.boolean :gift_giver
      t.boolean :gift_receiver
      t.boolean :investor

      t.timestamps
    end

    add_index :project_pois, :project_id
    add_index :project_pois, :user_id
  end

  def self.down
    drop_table :project_pois
  end
end
