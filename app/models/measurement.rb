class Measurement < ActiveRecord::Base

belongs_to :indicator_measurement

validates_presence_of :value
validates_presence_of :indicator_measurement_id

end
