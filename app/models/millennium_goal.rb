class MillenniumGoal < ActiveRecord::Base
  acts_as_paranoid
  has_many :targets

  validates_presence_of :description
  validates_uniqueness_of :description

  def to_label  
    "#{description}"
  end

  def target_count
    return targets.count
  end
end
