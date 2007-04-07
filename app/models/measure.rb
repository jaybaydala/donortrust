class Measure < ActiveRecord::Base
  has_many :milestones
  belongs_to :measure_category
  #belongs_to :user

  validates_presence_of :measure_category_id
  #validates_presence_of :user_id

  validate do |measure|
    # In each of the 'unless' conditions, true means that the association is reloaded,
    # if it does not exist, nil is returned
    unless measure.measure_category( true )
      measure.errors.add :measure_category_id, 'does not exist'
    end
  end

  # Determine if an object instance is a Measure
  def self.is_a_measure?( object )
    #return object.class == self.class
    #return object.class.to_s == self.class.to_s
    return object.class.to_s == "Measure"
  end
end
