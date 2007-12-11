class FinancialSource < ActiveRecord::Base
  belongs_to :project 
  
  validates_presence_of :source
  validates_presence_of :amount
#  validates_presence_of :project
  
  attr_accessor :should_destroy_source
  
  def should_destroy_source?
    should_destroy_source.to_i == 1
  end
  
end
