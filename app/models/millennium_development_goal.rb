class MillenniumDevelopmentGoal < ActiveRecord::Base

  #has_and_belongs_to_many :projects
  
  def to_label  
    "#{description}"
  end


end
