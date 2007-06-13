class Project < ActiveRecord::Base
  after_save  :create_project_history
  after_save :save_project_history  
  
  belongs_to :project_status
  belongs_to :project_category
  belongs_to :program
  has_many :project_histories
  validates_presence_of :program
  
  def create_project_history
    if Project.exists?(self.id)
      @create_project_history_ph = ProjectHistory.new_audit(Project.find(self.id))
    end
  end
  
  def get_dollars_raised
    @result = number_to_currency(Project.find(self.id).dollars_raised, :precision => 2)  
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
    @total = self.find(:all).size    
  end
  def self.get_projects
    @all_projects = self.find(:all)   
  end
  
  def days_remaining
    @days_remaining = (self.end_date - Time.now) / 86400 #number of seconds in a day
  end
  
end
