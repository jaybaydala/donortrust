class Rank < ActiveRecord::Base
  
  belongs_to :project
  belongs_to :rank_type 
  belongs_to :rank_value
   
   
  validates_presence_of :rank_type_id
  validates_presence_of :rank_value_id
  
end
 
  
  
