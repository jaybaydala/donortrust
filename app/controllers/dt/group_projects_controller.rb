class Dt::GroupProjectsController < DtApplicationController
  before_filter :login_required, :only => :destroy
  def index
    @group = Group.find(params[:group_id])
    
    @projects_invested = []
    projects_invested_ids = []
    investments = Investment.find(:all, :conditions => {:group_id => @group}, :include => :project)
    investments.each do |investment|
      @projects_invested << investment.project
      projects_invested_ids << investment.project.id
    end
    @projects_watched = @group.projects.find(:all, :conditions => ["projects.id NOT IN (?)", projects_invested_ids.split(',')])
  end
  
  def destroy
    @group = Group.find(params[:group_id])
    @project = Project.find(params[:id])
    @group.projects.delete @project
    respond_to do |format|
      format.html {
        flash[:notice] = "You have removed the &quot;@project.name&quot; from the group"
        redirect_to dt_group_projects_path(@group)
      }
    end
  end
  
  protected
  def authorized?
    if ['destroy'].include?(params[:action])
      return false unless logged_in?
      @group = Group.find(params[:group_id])
      return false unless @group.member(current_user)
      return false unless @group.member(current_user).admin?
    end
    true
  end
  
  def access_denied
    if ['destroy'].include?(params[:action])
      @group = Group.find(params[:group_id])
      redirect_to dt_group_projects_path(@group) and return false
    end
    super
  end
end
