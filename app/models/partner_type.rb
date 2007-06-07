class PartnerType < ActiveRecord::Base
  
  validates_length_of :name, :maximum => 50
  validates_presence_of :name
  
end
