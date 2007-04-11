class Country < ActiveRecord::Base

belongs_to :continent

  validates_presence_of :continent_id
  
  def validate
    begin
      Continent.find(self.continent_id)
    rescue ActiveRecord::RecordNotFound
      errors.add_to_base("Continent with id=#{self.continent_id} doesn't exist.")
    end
  end
end
