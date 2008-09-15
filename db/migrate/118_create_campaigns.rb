class CreateCampaigns < ActiveRecord::Migration
  def self.up
    create_table :campaigns do |t|
      # indentity stuff
      t.string :email
      t.string :name
      t.string :short_name
      t.text :description
      t.integer :user_id
      t.integer :campaign_type_id
      t.string :picture
      
      # waiting to be authorized by a CF admin
      t.boolean :pending
      
      #money stuff
      t.integer :fundraising_goal
      t.string :goal_currency
      
      t.integer :fee_amount
      t.string  :fee_currency
      
      # dates
      t.datetime :start_date
      t.datetime :end_date
      
      #wall
      t.references :wall
      
      #news
      t.references :news
      
      # address
      t.string :address
      t.string :address_2
      t.string :city
      t.string :province
      t.string :country
      t.string :postalcode
      
      #teams stuff
      t.boolean :require_team_authorization
      t.boolean :allow_multiple_teams
      t.integer :max_number_of_teams
      t.integer :max_size_of_teams
      t.integer :max_participants
      t.timestamps
    end
    

  end

  def self.down
    drop_table :campaigns
  end
end
