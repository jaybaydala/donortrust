class CreateTeams < ActiveRecord::Migration
  def self.up
    create_table :teams do |t|
      # references
      t.references :campaign
      t.references :user
      t.string :picture
      
      # config stuff
      t.boolean :pending
      t.boolean :ok_to_contact
      t.boolean :require_authorization
      
      # team details
      t.string :name
      t.string :contact_email
      t.string :short_name
      t.text   :description
      t.integer :goal
      t.string  :goal_currency
      
      t.timestamps
    end
  end

  def self.down
    drop_table :teams
  end
end
