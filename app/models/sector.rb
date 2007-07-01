class Sector < ActiveRecord::Base

  validates_presence_of :name
  validates_presence_of :description
  validates_uniqueness_of :name
  

end
