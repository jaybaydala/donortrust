class Dt::GroupProjectsController < DtApplicationController
  def index
    @group = Group.find(params[:group_id])
    
    @projects_invested = []
    projects_invested_ids = []
    investments = Investment.find(:all, :conditions => {:group_id => @group}, :include => :project)
    investments.each do |investment|
      @projects_invested << investment.project
      projects_invested_ids << investment.project.id
    end
    @projects_watched = @group.projects.find(:all, :conditions => ["projects.id NOT IN (?)", projects_invested_ids.split(', ')])
  end
  
  def destroy
  end
end
