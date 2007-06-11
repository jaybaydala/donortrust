class ProjectHistory < ActiveRecord::Base
  belongs_to :project
  belongs_to :project_status
  belongs_to :project_category
  belongs_to :bus_user

  validates_presence_of :project_id
  
  include BusAdmin::UserInfo
    
  def validate
    begin
      Project.find(self.project_id)
    rescue ActiveRecord::RecordNotFound
      errors.add_to_base("Project with id=#{self.project_id} doesn't exist.")
    end
  end
  
  def self.new_audit( project )
    raise ArgumentError, "need a Project, not a '#{project.class.to_s}'" if not Project.is_a_project?( project )
    project_history                          = ProjectHistory.new(:project_id => project.id)
    project_history.expected_completion_date = project.expected_completion_date
    project_history.project_status_id        = project.project_status_id
    project_history.project_category_id      = project.project_category_id
    project_history.description              = project.description
    project_history.total_cost               = project.total_cost
    project_history.dollars_spent            = project.dollars_spent
    project_history.start_date               = project.start_date
    project_history.date                     = Time.now
    project_history.end_date                 = project.end_date
    project_history.bus_user_id              = current_user.id
    return project_history
  end
  
end
