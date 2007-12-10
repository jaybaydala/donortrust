class FinancialSource < ActiveRecord::Base
  belongs_to :project 
  
  validates_presence_of :source
  validates_presence_of :amount
#  validates_presence_of :project
  
end
