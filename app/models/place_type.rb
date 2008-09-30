class PlaceType < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  
  class << self
    def continent
      find(:first, :conditions => ["name LIKE ?", "Continent"])
    end
    def country
      find(:first, :conditions => ["name LIKE ?", "Country"])
    end
    def state
      find(:first, :conditions => ["name LIKE ?", "State"])
    end
    def district
      find(:first, :conditions => ["name LIKE ?", "District"])
    end
    def region
      find(:first, :conditions => ["name LIKE ?", "Region"])
    end
    def city
      find(:first, :conditions => ["name LIKE ?", "City"])
    end
    alias_method :nation, :country
    alias_method :community, :city
  end
end
