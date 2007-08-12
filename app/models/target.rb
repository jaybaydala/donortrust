class Target < ActiveRecord::Base

belongs_to :millennium_goal
has_many :indicators

  validates_presence_of :description
  validates_uniqueness_of :description

  validate do |me|
    # In each of the 'unless' conditions, true means that the association is reloaded,
    # if it does not exist, nil is returned
    unless me.millennium_goal( true )
      me.errors.add :millennium_goal_id, 'does not exist'
    end
  end

  def to_label  
    "#{description}"
  end

  def destroy
    result = false
    if indicators.count > 0
#      errors.add_to_base( "Can not destroy a #{self.class.to_s} that has Indicators" )
      raise( "Can not destroy a #{self.class.to_s} that has Indicators" )
    else
      result = super
    end
    return result
  end

  def indicator_count
    return indicators.count
  end
end
