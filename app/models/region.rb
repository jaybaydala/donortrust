class Region < ActiveRecord::Base

belongs_to :country
has_many :urban_centre, :dependent => :destroy

  validates_presence_of :country_id
  validates_presence_of :name
  
  def validate
    begin
      Country.find(self.country_id)
    rescue ActiveRecord::RecordNotFound
      errors.add_to_base("Country with id=#{self.country_id} doesn't exist.")
    end
  end
  def to_label
    "#{region_name}"
  end
end
