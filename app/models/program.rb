class Program < ActiveRecord::Base

  has_one :contact

  validates_presence_of :program_name
  validates_uniqueness_of :program_name
  
end
