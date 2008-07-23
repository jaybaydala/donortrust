class CauseLimit < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :cause
  
  def validate
    errors.add("#{Cause.find(self.cause_id).name} is already in the list of acceptable causes for this campaign and therefore ") unless CauseLimit.find_by_cause_id_and_campaign_id(self.cause_id,self.campaign_id) == nil
  end
end
