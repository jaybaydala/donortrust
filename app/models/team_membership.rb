class TeamMembership < ActiveRecord::Base
  belongs_to :team
  belongs_to :user

  validates_presence_of :user
  validates_presence_of :team
  validate :one_team_for_member_per_campaign
  validate :participant_in_campaign

  def participant
    Participant.find(:first, :conditions => { :user_id => self.user_id, :campaign_id => team.campaign_id })
  end

  protected
    def one_team_for_member_per_campaign
      teams = self.team.campaign.teams.reload
      teams.each do |t|
        if t.users.include?(self.user)
          errors.add(:user_id, "can't join another team in this campaign")
        end
      end
    end

    def participant_in_campaign
      if !self.team.campaign.users.reload.include?(self.user)
        errors.add(:user_id, "must be a participant of the campaign first")
      end
    end
end