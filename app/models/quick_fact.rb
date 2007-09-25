class QuickFact < ActiveRecord::Base
  
  #has_many :geography_quick_fact_refs
  belongs_to :quick_fact_type
 
  validates_presence_of :name 
  validates_presence_of :type
  validates_presence_of :quick_fact_type
    
end
