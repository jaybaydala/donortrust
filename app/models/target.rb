class Target < ActiveRecord::Base

belongs_to :millennium_development_goal
  def to_label  
    "#{description}"
  end


end
