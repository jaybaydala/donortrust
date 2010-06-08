class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.integer :user_id
      t.string :short_name
      t.text :description
    end
  end

  def self.down
    drop_table :profiles
  end
end
