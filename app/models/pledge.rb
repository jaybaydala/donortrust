class Pledge < ActiveRecord::Base
  belongs_to :participant
  belongs_to :deposit
  
  attr_accessor :amount 
end
