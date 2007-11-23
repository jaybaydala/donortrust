class Measure < ActiveRecord::Base
  acts_as_paranoid
  belongs_to  :millennium_goal
  has_many    :key_measures

  validates_presence_of :description
  validates_uniqueness_of :description

  
  def to_label
    "#{description}"
  end


  def key_measures_count
    return key_measures.count
  end
end
