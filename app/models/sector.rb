class Sector < ActiveRecord::Base
  has_and_belongs_to_many :projects
  has_many :country_sectors
  has_many :countries, :through => :country_sectors

  validates_presence_of :name, :description
  validates_uniqueness_of :name

  def destroy
    result = false
    if projects.count > 0
#      errors.add_to_base( "Can not destroy a #{self.class.to_s} that has Projects" )
      raise( "Can not destroy a #{self.class.to_s} that has Projects" )
    else
      if countries.count > 0
#        errors.add_to_base( "Can not destroy a #{self.class.to_s} that has Countries" )
        raise( "Can not destroy a #{self.class.to_s} that has Countries" )
      else
        result = super
      end
    end
    return result
  end

  def project_count
    return projects.count
  end

  def country_count
    return countries.count
  end
end
