class Project < ActiveRecord::Base
  after_save  :create_project_history
  after_save :save_project_history  
  
  belongs_to :project_status
  belongs_to :project_category
  belongs_to :program
  belongs_to :partner
  has_many :project_histories
  has_many :milestones
  has_one   :urban_centre
  belongs_to :contact
  validates_presence_of :program
  
  def create_project_history
    if Project.exists?(self.id)
      @create_project_history_ph = ProjectHistory.new_audit(Project.find(self.id))
    end
  end
    
  def get_percent_raised
    if self.total_cost > 0 
      return (dollars_raised * 100 / total_cost)
    end
  end
  
  def save_project_history
    if (@create_project_history_ph)
      @create_project_history_ph.save
      @create_project_history_ph = nil
    end
  end
  
  def self.is_a_project?(object)
    return object.class.to_s == "Project"
  end
  
  def self.total_projects
    return self.find(:all).size    
  end
  
  def self.completed_projects
    return self.find(:all, :conditions => "project_status_id => 1")     
  end
  
  def total_milestones
    return (self.milestones.find(:all)).size
  end
  
  def get_number_of_milestones_by_status(status)
    milestones = self.milestones.find(:all, :conditions => "milestone_status_id = " + status.to_s )    
    return milestones.size unless milestones == nil 
  end
  
  def get_milestones
    return self.milestones.find(:all, :conditions => "project_id = " + self.id.to_s)
  end
  
  def self.get_projects
    return self.find(:all)   
  end
  
  def self.get_project(project_id)
    return self.find(project_id)   
  end
  
  def days_remaining
    return (self.end_date - Time.now) / 86400 #number of seconds in a day
  end
  
  def self.percent_raised
    return dollars_raised * 100 / total_cost
  end  
  
  def self.total_percent_raised
    return self.total_money_raised * 100 / self.total_costs
  end 
  
  def self.projects_nearing_end(days_until_end)
    @projects = Project.find(:all) 
    @projects_near_end = Array.new
    for aProject in @projects
      if ((aProject.end_date - Time.now) / 86400) <= days_until_end    
          @projects_near_end << aProject
      end
    end
    return @projects_near_end
  end
  
  def self.total_money_raised
    return self.sum(:dollars_raised)
  end
  
  def self.total_costs
    return self.sum(:total_cost)
  end
  
  def self.total_money_spent
    return self.sum(:dollars_spent)
  end
  
end
