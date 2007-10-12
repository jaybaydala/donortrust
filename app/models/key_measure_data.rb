class Measurement < ActiveRecord::Base
  belongs_to :key_measure

  validates_presence_of :value
  validates_presence_of :date

  validate do |me|
    # In each of the 'unless' conditions, true means that the association is reloaded,
    # if it does not exist, nil is returned
    unless me.indicator_measurement( true )
      me.errors.add :key_measure_id, 'does not exist'
    end
  end
  
  def name
    return "#{value}"
  end
end
