class Region < ActiveRecord::Base

belongs_to :country
belongs_to :region_type

  validates_presence_of :country_id
  validates_presence_of :region_type_id
  
  def validate
    begin
      Country.find(self.country_id)
    rescue ActiveRecord::RecordNotFound
      errors.add_to_base("Country with id=#{self.country_id} doesn't exist.")
    end
  end

end
