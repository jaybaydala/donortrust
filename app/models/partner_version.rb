class PartnerVersion < ActiveRecord::Base
  
  belongs_to    :partner
  belongs_to    :partner_type
  belongs_to    :partner_status
  #has_and_belongs_to_many :contacts #is this the right relationship? 
  
end
