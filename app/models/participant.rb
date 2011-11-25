class Participant < ActiveRecord::Base
  belongs_to :user
  belongs_to :campaign
  has_many :campaign_donations

end