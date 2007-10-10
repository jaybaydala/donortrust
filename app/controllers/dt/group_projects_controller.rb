class Dt::GroupProjectsController < DtApplicationController
  def index
    @group = Group.find(params[:group_id])
    @projects = @group.projects
  end
  
  def new
  end
  
  def create
  end
  
  def destroy
  end
end
