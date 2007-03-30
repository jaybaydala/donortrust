class Program < ActiveRecord::Base
 belongs_to :contact
  validates_presence_of :program_name
  validates_uniqueness_of :program_name
  
end
