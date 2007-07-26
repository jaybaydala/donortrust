class Project < ActiveRecord::Base
  after_save :create_project_history
  after_save :save_project_history  
  
  belongs_to :project_status
  belongs_to :program
  belongs_to :partner
  has_many :project_histories
  has_many :milestones
  belongs_to :urban_centre
  belongs_to :contact
  has_and_belongs_to_many :groups
  validates_presence_of :program_id
    
  def create_project_history
    if Project.exists?(self.id)
      @create_project_history_ph = ProjectHistory.new_audit(Project.find(self.id))
    end
  end

  def save_project_history
    if (@create_project_history_ph)
      @create_project_history_ph.save
      @create_project_history_ph = nil
    end
  end
  
  def destroy
    result = false
    if milestones.count > 0
#      errors.add_to_base( "Can not destroy a #{self.class.to_s} that has Milestones" )
      raise( "Can not destroy a #{self.class.to_s} that has Milestones" )
    else
      result = super
    end
    return result
  end

  def milestones_count
    return Milestone.find(:all).size
  end
  
  def self.total_percent_raised
    percent_raised = 100
    unless self.total_costs == nil or self.total_costs == 0
      percent_raised = self.total_money_raised * 100 / self.total_costs      
      if percent_raised > 100 then percent_raised = 100 end
    else
      return percent_raised
    end
  end 
  
  def get_number_of_milestones_by_status(status)
    milestones = self.milestones.find(:all, :conditions => "milestone_status_id = " + status.to_s )    
    return milestones.size unless milestones == nil     
  end
  
  def days_remaining
    result = nil
    result = end_date - Date.today if end_date != nil
    return result
  end
  
  def village
    self.urban_centre
  end
   
  def get_percent_raised
    percent_raised = 0
    if self.total_cost > 0 
      percent_raised = (dollars_raised * 100 / total_cost)
      if percent_raised > 100 then percent_raised = 100 end
    end
    return percent_raised
  end
  
  
  def self.projects_nearing_end(days_until_end)
    @projects = Project.find(:all) 
    @projects_near_end = Array.new
    for aProject in @projects
      if (aProject.end_date - Date.today) <= days_until_end  
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
  
  def village
    self.urban_centre
  end
  
  def self.is_a_project?(object)
    return object.class.to_s == "Project"
  end
end
