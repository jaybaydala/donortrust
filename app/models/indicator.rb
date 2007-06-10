class Indicator < ActiveRecord::Base
belongs_to :target

  def to_label  
    "#{description}"
  end


end
