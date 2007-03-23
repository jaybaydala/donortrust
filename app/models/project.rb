class Project < ActiveRecord::Base

  has_many :project_histories
  belongs_to :project_status
  belongs_to :project_category
  
  validates_presence_of :name
  validates_uniqueness_of :name  

  def save_with_audit
  
    save_result = false
    
    if( self.save )
      project_history                          = ProjectHistory.new(:project_id => self.id)
      project_history.expected_completion_date = self.expected_completion_date
      project_history.project_status_id        = self.project_status_id
      project_history.project_category_id      = self.project_category_id
      save_result                              = project_history.save
    end
    
    return save_result
    
  end
  
  def self.is_a_project?( object )
    return object.class.to_s == "Project"
  end  

end
