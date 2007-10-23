class KeyMeasure < ActiveRecord::Base
  has_many    :key_measure_datas
  belongs_to  :project
  belongs_to  :measure
  has_and_belongs_to_many :millennium_goals


  validates_presence_of :project_id
  validates_presence_of :measure_id
  validate do |me|
    # In each of the 'unless' conditions, true means that the association is reloaded,
    # if it does not exist, nil is returned
    unless me.project( true )
      me.errors.add :project_id, 'does not exist'
    end
    unless me.measure( true )
      me.errors.add :measure_id, 'does not exist'
    end
    
  end

  
  def destroy
    result = false
    if key_measure_data.count > 0
#      errors.add_to_base( "Can not destroy a #{self.class.to_s} that has Measurements" )
      raise( "Can not destroy a #{self.class.to_s} that has Measurements" )
    else
      result = super
    end
    return result
  end

  def to_label
    return "#{measure.description}"
  end

  def measurement_count
    return key_measure_datas.count
  end
end

