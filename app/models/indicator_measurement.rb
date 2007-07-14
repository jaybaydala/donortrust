class IndicatorMeasurement < ActiveRecord::Base

belongs_to  :project
belongs_to  :indicator
has_many :frequency_type


validates_presence_of :frequency
validates_presence_of :units

end
