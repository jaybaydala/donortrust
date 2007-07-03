class Continent < ActiveRecord::Base
  has_many :countries  
  def to_label  
    "#{continent_name}"  
  end 
end
