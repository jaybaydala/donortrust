require 'acts_as_paranoid_versioned'
class Partner < ActiveRecord::Base
  acts_as_paranoid_versioned

  belongs_to    :partner_type
  belongs_to    :partner_status
  has_many      :projects
  has_and_belongs_to_many :contacts #is this the right relationship? 
  has_many      :programs, :through => :projects
  has_many      :quick_fact_partners

  validates_presence_of :name
  validates_length_of   :name, :maximum => 50
  validates_length_of :description, :within => 1..1000, :too_long => "too long (max 1000)", :too_short => " can't be blank"

  validate do |me|
    # In each of the 'unless' conditions, true means that the association is reloaded,
    # if it does not exist, nil is returned
    unless me.partner_status( true )
      me.errors.add :partner_status_id, 'does not exist'
    end
    unless me.partner_type( true )
      me.errors.add :partner_type_id, 'does not exist'
    end
  end

  def total_projects    
    return (self.projects.find(:all)).size
  end
  
  def get_number_of_projects_by_status(status)
    projects = self.projects.find(:all, :conditions => "project_status_id = " + status.to_s )    
    return projects.size unless projects == nil 
  end
  
  def get_number_of_projects
    return Project.find(:all, :conditions => "partner_id = " + id.to_s).size   
  end
  
  def get_number_of_programs
    return Program.find(:all, :conditions => "id = " + id.to_s).size   
  end
  
  def get_total_costs
    projects = Project.find(:all, :conditions => "partner_id = " + id.to_s)    
    total_cost = 0
    projects.each do |project|
      total_cost += project.total_cost
    end
    return total_cost
  end
  
  def get_total_raised    
    projects = Project.find(:all, :conditions => "partner_id = " + id.to_s)    
    total_raised = 0
    projects.each do |project|
      total_raised += project.dollars_raised
    end
    return total_raised
  end
  
  def get_total_percent_raised    
    percent_raised = 0
    if get_total_costs > 0
      percent_raised = ((get_total_raised / get_total_costs) * 100).floor
    end
    if percent_raised > 100 then percent_raised = 100 end
    return percent_raised
  end
end
