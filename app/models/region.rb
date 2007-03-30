class Region < ActiveRecord::Base

belongs_to :nation

  validates_presence_of :nation_id
  
  def validate
    begin
      Nation.find(self.nation_id)
    rescue ActiveRecord::RecordNotFound
      errors.add_to_base("Nation with id=#{self.nation_id} doesn't exist.")
    end
  end

end
