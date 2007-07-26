class Contact < ActiveRecord::Base
  has_many :programs
  has_many :projects
  belongs_to :continent
  belongs_to :country
  belongs_to :region
  belongs_to :urban_centre
  has_and_belongs_to_many :partners
  
  validates_presence_of :first_name
  validates_presence_of :last_name
  #validates_uniqueness_of :first_name, :last_name, :case_sensitive => false  
  
  def to_label
    "#{last_name}, #{first_name}"
  end
  
  def fullname    
    "#{first_name} #{last_name}"
  end
end
