class Country < ActiveRecord::Base
belongs_to :continent
has_many :regions
  def to_label  
    "#{name}"
  end
end
