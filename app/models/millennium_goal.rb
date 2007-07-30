class MillenniumGoal < ActiveRecord::Base
  has_many :targets

  validates_presence_of :description
  validates_uniqueness_of :description

  def to_label  
    "#{description}"
  end

  def destroy
    result = false
    if targets.count > 0
#      errors.add_to_base( "Can not destroy a #{self.class.to_s} that has Targets" )
      raise( "Can not destroy a #{self.class.to_s} that has Targets" )
    else
      result = super
    end
    return result
  end

  def target_count
    return targets.count
  end
end
