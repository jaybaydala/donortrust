class Team < ActiveRecord::Base
  belongs_to :user
  belongs_to :campaign
  has_many :team_memberships
  has_many :users, :through => :team_memberships

end