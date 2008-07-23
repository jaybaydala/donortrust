class PlaceLimit < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :place
  
  def validate
    errors.add("#{Place.find(self.place_id).name} is already in the list of acceptable places for this campaign and therefore ") unless PlaceLimit.find_by_place_id_and_campaign_id(self.place_id,self.campaign_id) == nil
  end
end
