class Contact < ActiveRecord::Base
  has_many :programs
  has_and_belongs_to_many :partners
  
  validates_presence_of :first_name
  validates_presence_of :last_name
end
