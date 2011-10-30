class Campaign < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :sectors
  has_many :participants
  has_many :teams
  has_friendly_id :url, :use_slug => true

  validates_presence_of :name
  validates_presence_of :user
  validates_presence_of :url

  before_save :copy_slug
  after_save :set_creator_as_participant


  protected
    def copy_slug
      self.url = self.friendly_id
    end

    def set_creator_as_participant
      Participant.create(:user => self.user, :campaign => self)
    end
end
