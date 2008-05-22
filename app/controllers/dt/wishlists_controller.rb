class Dt::WishlistsController < DtApplicationController
  before_filter :login_required

  def new
    redirect_to dt_projects_path and return if !params[:project_id]
    @project = Project.find(params[:project_id])
    respond_to do |format|
      format.html
    end
  end
  
  def create
    redirect_to dt_projects_path and return if !params[:project_id]
    @project = Project.find(params[:project_id])
    @group = Group.find(params[:group_id])
    @saved = @group.projects << @project
    respond_to do |format|
      format.html do
        if @saved
          redirect_to dt_wishlists_path(current_user) and return if params[:watchlist_type] == 'personal'
          redirect_to dt_group_group_projects_path(@group)
        else
          render :action => "new"
        end
      end
    end
  end
end
