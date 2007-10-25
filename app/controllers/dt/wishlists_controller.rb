class Dt::WishlistsController < DtApplicationController
  before_filter :login_required

  def new
    redirect_to dt_projects_path and return if !params[:project_id]
    @project = Project.find(params[:project_id])
  end
  
  def create
    redirect_to dt_projects_path and return if !params[:project_id]
    @project = Project.find(params[:project_id])
    if matchdata = params[:watchlist_type].match(/^group-(\d*)/)
      @group = Group.find(matchdata[1])
      @saved = @group.projects << @project
    end
    respond_to do |format|
      format.html do
        if @saved
          redirect_to dt_wishlists_path(current_user) and return if params[:watchlist_type] == 'personal'
          redirect_to dt_group_projects_path(@group)
        else
          render :action => "new"
        end
      end
    end
  end
end
