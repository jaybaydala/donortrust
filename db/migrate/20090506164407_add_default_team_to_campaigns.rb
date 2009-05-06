class AddDefaultTeamToCampaigns < ActiveRecord::Migration
  def self.up
    add_column "campaigns", "default_team_id", :integer
  end

  def self.down
    remove_column "campaigns", "default_team_id"
  end
end
