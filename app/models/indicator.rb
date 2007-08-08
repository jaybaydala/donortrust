class Indicator < ActiveRecord::Base
  belongs_to  :target
  has_many    :indicator_measurements

  validates_presence_of :target_id
  validates_presence_of :description
  validates_uniqueness_of :description

  def to_label  
    "#{description}"
  end
end
