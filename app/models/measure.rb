class Measure < ActiveRecord::Base
  validates_presence_of :measure_type, :measure_qty, :user_id, :date
end
