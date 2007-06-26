class Country < ActiveRecord::Base

belongs_to :continent
  def to_label  
    "#{name}"
  end
end
