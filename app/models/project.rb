class Project < ActiveRecord::Base
  after_save :create_project_history
  after_save :save_project_history  
  
  belongs_to :project_status
  belongs_to :program
  belongs_to :partner
  has_many :project_histories
  has_many :milestones, :dependent => :destroy
  belongs_to :urban_centre
  belongs_to :contact
  has_and_belongs_to_many :groups
  has_and_belongs_to_many :sectors
#  validates_presence_of :program_id
  
  has_many :you_tube_videos, :through => :project_you_tube_videos
  has_many :project_you_tube_videos, :dependent => :destroy
  has_many :flickr_images, :through => :project_flickr_images
  has_many :project_flickr_images, :dependent => :destroy
  
  validate do |me|
    # In each of the 'unless' conditions, true means that the association is reloaded,
    # if it does not exist, nil is returned
    unless me.program( true )
      me.errors.add :program_id, 'does not exist'
    end
  end
  
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
  
  def get_all_you_tube_videos
    @you_tube_videos = Array.new
    for project_you_tube_video in self.project_you_tube_videos
      @you_tube_videos.push(project_you_tube_video.you_tube_video)
    end
    @you_tube_videos
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
