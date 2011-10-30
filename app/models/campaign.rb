class Campaign < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :sectors
  has_many :participants
  has_many :teams

  validates_presence_of :name

  after_save :set_creator_as_participant


  protected
    def set_creator_as_participant
      Participant.create(:user => self.user, :campaign => self)
    end
end
