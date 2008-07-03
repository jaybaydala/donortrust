class CreateTeams < ActiveRecord::Migration
  def self.up
    create_table :teams do |t|
      t.references :campaign
      t.references :user
      
      t.string :name
      t.boolean :ok_to_contact
      t.boolean :require_authorization
      t.string :contact_email
      t.string :short_name
      
      t.timestamps
    end
  end

  def self.down
    drop_table :teams
  end
end
