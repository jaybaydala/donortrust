class MillenniumDevelopmentGoal < ActiveRecord::Base

  def to_label  
    "#{description}"
  end


end
