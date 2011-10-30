class TeamMembership < ActiveRecord::Base
  belongs_to :team
  belongs_to :user

  validates_presence_of :user
  validates_presence_of :team
  validate :one_team_for_member_per_campaign

  protected
    def one_team_for_member_per_campaign
      teams = self.team.campaign.teams
      teams.each do |t|
        if t.users.include?(self.user)
          errors.add(:user, "can't join another team in this campaign")
        end
      end
    end
end