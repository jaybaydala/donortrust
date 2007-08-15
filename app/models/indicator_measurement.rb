class IndicatorMeasurement < ActiveRecord::Base
  has_many    :measurements
  belongs_to  :project
  belongs_to  :indicator
  belongs_to  :frequency_type

  validates_presence_of :units
  validate do |me|
    # In each of the 'unless' conditions, true means that the association is reloaded,
    # if it does not exist, nil is returned
    unless me.project( true )
      me.errors.add :project_id, 'does not exist'
    end
    unless me.indicator( true )
      me.errors.add :indicator_id, 'does not exist'
    end
    unless me.frequency_type( true )
      me.errors.add :frequency_type_id, 'does not exist'
    end
  end

  def destroy
    result = false
    if measurements.count > 0
#      errors.add_to_base( "Can not destroy a #{self.class.to_s} that has Measurements" )
      raise( "Can not destroy a #{self.class.to_s} that has Measurements" )
    else
      result = super
    end
    return result
  end

  def to_label
    return "#{units}"
  end

  def measurement_count
    return measurements.count
  end
end
