class Program < ActiveRecord::Base
  has_many :projects
  belongs_to :contact
  validates_presence_of :contact_id
  validates_presence_of :program_name
  validates_uniqueness_of :program_name
  
  def to_label
    "#{program_name}"
  end
  
  def self.total_programs
    return self.find(:all).size
  end
  
  def self.get_programs
    return self.find(:all)   
  end
end
