class BusUserType < ActiveRecord::Base
  validates_presence_of :name
  has_and_belongs_to_many :bus_secure_actions
  
  
end
