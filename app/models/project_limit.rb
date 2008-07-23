class ProjectLimit < ActiveRecord::Base
  belongs_to :project
  belongs_to :campaign
  
  def validate
    errors.add("#{Project.find(self.project_id).name} is already in the list of acceptable projects for this campaign and therefore ") unless ProjectLimit.find_by_project_id_and_campaign_id(self.project_id,self.campaign_id) == nil
  end
end
