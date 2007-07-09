
class BusSecureAction < ActiveRecord::Base
 belongs_to :bus_security_level
 has_and_belongs_to_many :bus_user_types
 
  def to_label
    "#{permitted_actions}(#{BusSecurityLevel.find(bus_security_level_id).controller})"
  end
  
end
