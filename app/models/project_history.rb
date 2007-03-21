class ProjectHistory < ActiveRecord::Base

  belongs_to :project

  validates_presence_of :project_id
  
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
    project_history.status_id                = project.status_id
    return project_history
  end
  
end
