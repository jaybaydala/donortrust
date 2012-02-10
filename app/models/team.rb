class Team < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :user
  has_many :team_memberships, :dependent => :destroy
  has_many :users, :through => :team_memberships

  validates_presence_of :name
  validates_numericality_of :goal, :greater_than => 0
  validate_on_create :creator_can_join_team

  after_create :add_creator_as_member

  def participants
    participants = []
    self.users.each do |u|
      participants << u.find_participant_in_campaign(self.campaign)
    end
    participants
  end

  def total_donations
    self.participants.inject(0) {|sum, participant| sum + participant.amount_raised}
  end

  def user_can_join?(user)
    teams = self.campaign.teams.reload
    teams.each do |t|
      if t.users.include?(user)
        return false
      end
    end
    if !self.campaign.users.reload.include?(user)
      return false
    end
    return true
  end

  protected
    def add_creator_as_member
      TeamMembership.create!(:team => self, :user => self.user)
    end

    def creator_can_join_team
      if !self.user_can_join?(self.user)
        errors.add(:user_id, "can't create another team in this campaign")
      end
    end
end