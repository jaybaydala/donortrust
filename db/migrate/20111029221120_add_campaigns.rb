class AddCampaigns < ActiveRecord::Migration
  def self.up
    create_table :campaigns do |t|
      t.string :name
      t.text :description
      t.integer :user_id
      t.string :url
      t.string :cached_slug

      t.timestamps
    end

  end

  def self.down
    drop_table :campaigns
  end
end
