class Contact < ActiveRecord::Base
  has_many :programs
  
    validates_presence_of :first_name
    validates_presence_of :last_name
end
