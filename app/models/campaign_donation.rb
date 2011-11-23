class CampaignDonation < ActiveRecord::Base
  belongs_to :user
  belongs_to :order
  belongs_to :campaign
  has_one :user_transaction, :as => :tx

  def name
    if self.user.present?
      self.user.name
    elsif self.order.present?
      self.order.name
    end
  end
end
