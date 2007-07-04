class Village < ActiveRecord::Base
#belongs_to :urban_centre

  validates_presence_of :village_group_id
  
  def validate
    begin
      VillageGroup.find(self.village_group_id)
    rescue ActiveRecord::RecordNotFound
      errors.add_to_base("Village Group with id=#{self.village_group_id} doesn't exist.")
    end
  end

end
