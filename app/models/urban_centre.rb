class UrbanCentre < ActiveRecord::Base

belongs_to  :region
belongs_to  :project

  validates_presence_of :region_id
  validates_presence_of :urban_centre_name
  
  def validate
    begin
      Region.find(self.region_id)
    rescue ActiveRecord::RecordNotFound
      errors.add_to_base("Region with id=#{self.region_id} doesn't exist.")
    end
  end
  def to_label
    "#{urban_centre_name}"
  end
end

