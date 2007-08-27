class FrequencyType < ActiveRecord::Base
  acts_as_paranoid
  has_many :indicator_measurements

  validates_presence_of :name, :active
  validates_uniqueness_of :name



  def indicator_measurement_count
    return indicator_measurements.count
  end
end
