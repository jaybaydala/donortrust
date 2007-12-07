class Cause < ActiveRecord::Base
  acts_as_paranoid
  
  validates_presence_of :name  
#  validates_uniqueness_of :name
  
  has_and_belongs_to_many :projects #changed from has_many :projects, passed tests
  has_and_belongs_to_many :millennium_goals
  has_and_belongs_to_many :sectors
  
  acts_as_textiled :description
end
