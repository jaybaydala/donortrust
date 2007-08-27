class Target < ActiveRecord::Base
  acts_as_paranoid
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

  def indicator_count
    return indicators.count
  end
end
