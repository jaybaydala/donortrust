class Continent < ActiveRecord::Base

has_many :nations
  
  validates_presence_of :continent_name
  validates_uniqueness_of :continent_name  

end
