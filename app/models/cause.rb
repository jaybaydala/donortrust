class Cause < ActiveRecord::Base
  acts_as_paranoid
  
  validates_presence_of :name  
  validates_uniqueness_of :name
  
   has_many :projects
   has_and_belongs_to_many :millennium_goals
   has_and_belongs_to_many :sectors
end
