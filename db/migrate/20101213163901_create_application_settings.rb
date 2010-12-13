class CreateApplicationSettings < ActiveRecord::Migration
  def self.up
    create_table :application_settings do |t|
      t.string :name
      t.string :slug
      t.string :value
      
      t.timestamps
    end
  end

  def self.down
    drop_table :application_settings
  end
end
