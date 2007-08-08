class FrequencyType < ActiveRecord::Base
  has_many :indicator_measurements

  validates_presence_of :name, :active
  validates_uniqueness_of :name

  def destroy
    result = false
    if indicator_measurements.count > 0
#      errors.add_to_base( "Can not destroy a #{self.class.to_s} that has Indicator Measurements" )
      raise( "Can not destroy a #{self.class.to_s} that has Indicator Measurements" )
    else
      result = super
    end
    return result
  end

  def indicator_measurement_count
    return indicator_measurements.count
  end
end
