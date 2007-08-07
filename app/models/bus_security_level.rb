class BusSecurityLevel < ActiveRecord::Base
has_many :bus_secure_actions, :dependent => :destroy
def to_label
  "#{controller}:#{id}"
end

end
