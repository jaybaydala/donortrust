class Indicator < ActiveRecord::Base
  belongs_to  :target
  has_many    :indicator_measurements

  validates_presence_of :description
  validates_uniqueness_of :description

  validate do |me|
    # In each of the 'unless' conditions, true means that the association is reloaded,
    # if it does not exist, nil is returned
    unless me.target( true )
      me.errors.add :target_id, 'does not exist'
    end
  end

  def to_label
    "#{description}"
  end

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
