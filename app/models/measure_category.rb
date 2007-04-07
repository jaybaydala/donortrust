class MeasureCategory < ActiveRecord::Base
  has_many :measures

  validates_presence_of :category
  validates_uniqueness_of :category
  validates_presence_of :description
end
