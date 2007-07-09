class BusSecurityLevel < ActiveRecord::Base
has_many :bus_secure_actions
def to_label
  "#{controller}:#{id}"
end

end
