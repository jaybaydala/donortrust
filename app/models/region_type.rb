class RegionType < ActiveRecord::Base
  has_many :regions

  validates_presence_of :name
  validates_uniqueness_of :name
  
  def destroy
    result = false
    if regions.count > 0
#      errors.add_to_base( "Can not destroy a #{self.class.to_s} that has Regions" )
      raise( "Can not destroy a #{self.class.to_s} that has Regions" )
    else
      result = super
    end
    return result
  end

  def region_count
    return regions.count
  end
end
