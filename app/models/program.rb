class Program < ActiveRecord::Base
  has_many :projects
  belongs_to :contact
  validates_presence_of :contact_id
  validates_presence_of :program_name
  validates_uniqueness_of :program_name
  
end
