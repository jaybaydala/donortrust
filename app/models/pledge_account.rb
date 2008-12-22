class PledgeAccount < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :team
  belongs_to :user
  has_many :user
  
  
  def self.generate_user_accounts(user)
    campaigns = Pledge.find(:all, :conditions => ["admin_user_id=? AND released=?", user, true], :select => "DISTINCT(campaign_id)").map{|p|p.campaign}
    campaigns = campaigns.select{|c| !c.nil? } # remove invalid campaigns
    # TODO - add in campaigns using a calculated Pledge.owner method
    accounts ||= campaigns.map do |campaign|
      generate_user_campaign_account(user, campaign)
    end
  end
  def self.generate_user_campaign_account(user, campaign)
    existing_account = PledgeAccount.find(:first, :conditions => ["campaign_id=? AND user_id=? AND team_id IS NULL", campaign, user])
    return existing_account unless existing_account.nil?
    pledge_account = PledgeAccount.create
    pledge_account.campaign = campaign
    pledge_account.user = user
    pledge_account.balance = Pledge.sum(:amount, :conditions => ["campaign_id=? and admin_user_id=?", campaign.id, user.id])
    # TODO - add to balance using a calculated Pledge.owner method
    pledge_account.save
    pledge_account
  end
end
