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
  
  def save_project_history
    if (@create_project_history_ph)
      @create_project_history_ph.save
      @create_project_history_ph = nil
    end
  end
  
  def self.is_a_project?(object)
    return object.class.to_s == "Project"
  end
end
