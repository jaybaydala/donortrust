class QuickFactSector < ActiveRecord::Base
  
  belongs_to :quick_fact
  belongs_to :sector  
     
  validates_presence_of   :quick_fact, :quick_fact_type
  
end
