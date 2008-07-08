class FinancialSource < ActiveRecord::Base
  belongs_to :project 
  belongs_to :partner
  
  validates_presence_of :source, :amount, :project
  
end
