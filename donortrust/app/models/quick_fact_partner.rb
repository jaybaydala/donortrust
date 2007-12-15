class QuickFactPartner < ActiveRecord::Base
  
  belongs_to :quick_fact
  belongs_to :partner
      
  validates_presence_of   :quick_fact_id, :partner_id
  
end
