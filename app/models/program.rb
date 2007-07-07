class Program < ActiveRecord::Base
  has_many :projects#, :dependent => :destroy
  belongs_to :contact
  validates_presence_of :contact_id
  validates_presence_of :program_name
  validates_uniqueness_of :program_name
  
  def to_label
    "#{program_name}"
  end

  def destroy
    result = false
    if projects.count > 0
#      errors.add_to_base( "Can not destroy a #{self.class.to_s} that has Projects" )
      raise( "Can not destroy a #{self.class.to_s} that has Projects" )
    else
      result = super
    end
    return result
  end

  def projects_count
    return projects.count
  end

  def self.total_programs
    return self.find(:all).size
  end
  
  def self.get_programs
    return self.find(:all)   
  end
end
