class FinancialSource < ActiveRecord::Base
  belongs_to :project 
  
  validates_presence_of :source, :amount, :project
  
end
