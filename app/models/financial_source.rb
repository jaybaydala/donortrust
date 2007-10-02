class FinancialSource < ActiveRecord::Base
  belongs_to :project 
  
  validates_numericality_of :amount
  validates_presence_of :source, :amount, :project
  
end
