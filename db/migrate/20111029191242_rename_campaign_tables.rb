class RenameCampaignTables < ActiveRecord::Migration
  def self.up
    rename_table :campaigns, :old_campaigns
    rename_table :teams, :old_teams
    rename_table :team_members, :old_team_members
    rename_table :participants, :old_participants
  end

  def self.down
    rename_table :old_campaigns, :campaigns
    rename_table :old_teams, :teams
    rename_table :old_team_members, :team_members
    rename_table :old_participants, :participants
  end
end
