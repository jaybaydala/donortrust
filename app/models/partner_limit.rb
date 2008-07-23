class PartnerLimit < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :partner
  
  def validate
    errors.add("#{Partner.find(self.partner_id).name} is already in the list of acceptable projects for this campaign and therefore ") unless PartnerLimit.find_by_partner_id_and_campaign_id(self.partner_id,self.campaign_id) == nil
  end
end
