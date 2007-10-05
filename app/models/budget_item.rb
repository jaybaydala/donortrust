class BudgetItem < ActiveRecord::Base
  
  belongs_to :project 
   
  validates_presence_of :project, :description, :cost
  validates_numericality_of :cost 
   
end
