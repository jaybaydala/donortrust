class Team < ActiveRecord::Base
  belongs_to :user
  belongs_to :campaign
  has_many :team_memberships, :dependent => :destroy
  has_many :users, :through => :team_memberships

  validates_presence_of :name
  validates_numericality_of :goal, :greater_than => 0
  validate :creator_can_join_team

  after_create :add_creator_as_member

  def user_can_join?(user)
    teams = self.campaign.teams
    teams.each do |t|
      return false if t.users.include?(user)
    end
    true
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