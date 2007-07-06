class Continent < ActiveRecord::Base
  has_many :countries, :dependent => :destroy
  
  validates_presence_of :continent_name
  validates_uniqueness_of :continent_name
  

  def to_label  
    "#{continent_name}"  
  end 
end
