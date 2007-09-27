class QuickFactSector < ActiveRecord::Base
  
  belongs_to :quick_fact
  belongs_to :sector  
     
  validates_presence_of   :quick_fact
  validates_presence_of   :description
  
end
