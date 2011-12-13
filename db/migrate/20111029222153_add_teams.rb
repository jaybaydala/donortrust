class AddTeams < ActiveRecord::Migration
  def self.up
    create_table :teams do |t|
      t.string :name
      t.text :description
      t.integer :user_id
      t.decimal :goal, :precision => 12, :scale => 2
      t.integer :campaign_id

      t.timestamps
    end

    create_table :team_memberships do |t|
      t.integer :team_id
      t.integer :user_id
    end
  end

  def self.down
    drop_table :teams
    drop_table :team_memberships
  end
end
