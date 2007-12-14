class MillenniumGoal < ActiveRecord::Base
  acts_as_paranoid
  has_and_belongs_to_many :key_measures
  has_and_belongs_to_many :causes
  
  validates_presence_of :name
  validates_uniqueness_of :name
  acts_as_textiled :description

end
