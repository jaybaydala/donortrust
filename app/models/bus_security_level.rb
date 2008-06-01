class BusSecurityLevel < ActiveRecord::Base
has_many :bus_secure_actions, :dependent => :destroy
validates_presence_of :controller
def to_label
  "#{controller}:#{id}"
end

end
