class Cause < ActiveRecord::Base
  belongs_to :sector 
  has_many :projects
  
  validates_presence_of :name
 
end
