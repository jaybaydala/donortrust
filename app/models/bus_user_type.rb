class BusUserType < ActiveRecord::Base

  has_and_belongs_to_many :bus_secure_actions
end
