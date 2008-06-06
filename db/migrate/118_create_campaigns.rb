class CreateCampaigns < ActiveRecord::Migration
  def self.up
    create_table :campaigns do |t|
      t.string :name
      t.text :description
      t.integer :user_id
      t.integer :campaign_type_id
      t.datetime :start_date
      t.datetime :start_end
      t.string :province
      t.string :address
      t.string :postalcode
      t.integer :place_type_id
      t.integer :fundraising_goal
      t.timestamps
    end
  end

  def self.down
    drop_table :campaigns
  end
end
