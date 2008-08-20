class Contact < ActiveRecord::Base
  acts_as_paranoid
  has_many :programs
  has_many :projects
  belongs_to :place
  belongs_to :partner
  belongs_to :user
 
  
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
