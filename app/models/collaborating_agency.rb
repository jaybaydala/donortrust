class CollaboratingAgency < ActiveRecord::Base
  belongs_to :project 
  
  validates_presence_of :agency_name, :responsibilities #, :project
end
