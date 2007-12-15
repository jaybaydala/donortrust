class RankType < ActiveRecord::Base
  
  has_many :ranks
    
  validates_presence_of :name
  
end
