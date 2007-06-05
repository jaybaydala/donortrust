class RegionType < ActiveRecord::Base

  has_many :regions

  validates_presence_of :region_type_name
  validates_uniqueness_of :region_type_name
  
  def to_label
    "#{region_type_name}"
  end
end
