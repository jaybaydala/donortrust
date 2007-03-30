class VillageGroup < ActiveRecord::Base

belongs_to :region

  validates_presence_of :region_id
  
  def validate
    begin
      Region.find(self.region_id)
    rescue ActiveRecord::RecordNotFound
      errors.add_to_base("Region with id=#{self.region_id} doesn't exist.")
    end
  end
end
