class Program < ActiveRecord::Base
  has_many :projects#, :dependent => :destroy
  belongs_to :contact
  validates_presence_of :contact_id
  validates_presence_of :name
  validates_uniqueness_of :name
  
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
  
  
  def get_total_costs
    projects = Project.find(:all, :conditions => "program_id = " + id.to_s)    
    total_cost = 0
    projects.each do |project|
      total_cost += project.total_cost
    end
    return total_cost
  end
  
  def get_total_raised    
    projects = Project.find(:all, :conditions => "program_id = " + id.to_s)    
    total_raised = 0
    projects.each do |project|
      total_raised += project.dollars_raised
    end
    return total_raised
  end
  
  def get_total_days_remaining
    projects = Project.find(:all, :conditions => "program_id = " + id.to_s)    
    total_days = 0
    projects.each do |project|
      total_days += project.days_remaining
    end
    return total_days
  end
  
  def get_percent_raised
    percent_raised = 0
    total_cost = get_total_costs
    if total_cost > 0 
      percent_raised = (get_total_raised * 100 / total_cost).floor
      if percent_raised > 100 then percent_raised = 100 end
    end    
    return percent_raised
  end
  
end
