class CollaboratingAgency < ActiveRecord::Base
  belongs_to :project 
  
  validates_presence_of :agency_name, :responsibilities #, :project
  attr_accessor :should_destroy_agency
  
  def should_destroy_agency?
    should_destroy_agency.to_i == 1
  end

end
