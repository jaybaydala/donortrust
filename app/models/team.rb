class Team < ActiveRecord::Base
  belongs_to :user
  belongs_to :campaign
  has_many :team_memberships
  has_many :users, :through => :team_memberships

  validates_presence_of :name
  validates_numericality_of :goal, :greater_than => 0

  after_create :add_creator_as_member

  protected
    def add_creator_as_member
      TeamMembership.create!(:team => self, :user => self.user)
    end
end