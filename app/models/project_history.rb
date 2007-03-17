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

end
