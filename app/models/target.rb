class Target < ActiveRecord::Base

belongs_to :millennium_goal

  validates_presence_of :millennium_goal_id
  validates_presence_of :description
validates_uniqueness_of :description

  def to_label  
    "#{description}"
  end


end
