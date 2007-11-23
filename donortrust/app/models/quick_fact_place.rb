class QuickFactPlace < ActiveRecord::Base
  belongs_to :quick_fact
  belongs_to :place    
        
  validates_presence_of   :quick_fact_id, :place_id 
   
end
