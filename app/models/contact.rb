class Contact < ActiveRecord::Base
  has_many :programs
  belongs_to :continent
  belongs_to :country
  belongs_to :region
  belongs_to :city
  has_and_belongs_to_many :partners
  
  validates_presence_of :first_name
  validates_presence_of :last_name
  
    def to_label
    "#{last_name}, #{first_name}"
  end
end
