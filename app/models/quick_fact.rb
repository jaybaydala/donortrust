class QuickFact < ActiveRecord::Base
  
  belongs_to :quick_fact_type
 
  validates_presence_of :name 
  validates_presence_of :type
  validates_presence_of :quick_fact_type
    
end
