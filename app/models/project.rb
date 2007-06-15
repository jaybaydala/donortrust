class Project < ActiveRecord::Base
  after_save  :create_project_history
  after_save :save_project_history  
  
  belongs_to :project_status
  belongs_to :project_category
  belongs_to :program
  has_many :project_histories
  has_many :milestones
  belongs_to :contact
  validates_presence_of :program
  
  def create_project_history
    if Project.exists?(self.id)
      @create_project_history_ph = ProjectHistory.new_audit(Project.find(self.id))
    end
  end
  
  def self.get_percent_raised
    return self.get_dollars_raised * 100 / self.get_total_cost
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
  
  def self.total_milestones
    return self.milestones
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
  
  def percent_raised
    return dollars_raised * 100 / total_cost
  end
end
