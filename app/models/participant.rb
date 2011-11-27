class Participant < ActiveRecord::Base
  belongs_to :user
  belongs_to :campaign
  has_many :campaign_donations

  def amount_raised
    self.campaign_donations.inject(0) {|sum, campaign_donation| sum + campaign_donation.amount}
  end

end