class Partner < ActiveRecord::Base
  acts_as_versioned

#  after_save  :create_partner_history
#  after_save :save_partner_history
  
  belongs_to    :partner_type
  belongs_to  :partner_status
  has_many      :partner_versions
  has_many      :projects
  has_and_belongs_to_many :contacts #is this the right relationship? 
  has_many    :programs, :through => :projects
  
  validates_presence_of :name, :partner_status_id, :partner_type_id
  validates_length_of   :name, :maximum => 50
  #validates_length_of   :description, :maximum => 1000
  validates_length_of :description, :within => 0..1000, :too_long => "too long (max 1000)", :too_short => " can't be blank"
  
  def create_partner_history
    if Partner.exists?(self.id)
      @create_partner_history_ph = PartnerHistory.new_audit(Partner.find(self.id))
    end
  end
  
  def save_partner_history
    if (@create_partner_history_ph)
      @create_partner_history_ph.save
      @create_partner_history_ph = nil
    end
  end
  
  def self.is_a_partner?(object)
    return object.class.to_s == "Partner"
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
