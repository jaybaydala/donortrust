class Campaign < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :sectors
  has_many :participants, :dependent => :destroy
  has_many :teams, :dependent => :destroy
  has_many :users, :through => :participants
  has_friendly_id :url, :use_slug => true

  validates_presence_of :name
  validates_presence_of :user
  validates_presence_of :url

  before_save :copy_slug
  after_save :set_creator_as_participant

  def user_can_participate?(user)
    if self.users.include?(user) #already a member
      return false
    end
    return true
  end

  def user_can_add_team?(user)
    if !self.users.include?(user)
      return false
    end
    self.teams.each do |t|
      if t.users.include?(user)
        return false
      end
    end
    return true
  end

  protected
    def copy_slug
      self.url = self.friendly_id
    end

    def set_creator_as_participant
      Participant.create!(:user => self.user, :campaign => self)
    end
end
