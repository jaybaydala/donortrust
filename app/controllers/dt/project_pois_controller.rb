class Dt::ProjectPoisController < DtApplicationController
 
  def unsubscribe
    @project_poi = ProjectPoi.find_by_token(params[:id])
    if @project_poi
      flash[:notice] = "You have been unsubscribed."
      @project_poi.update_attributes :unsubscribed => true
      redirect_to dt_project_path(@project_poi.project_id)
    else
      flash[:notice] = "We couldn't find a matching record to unsubscribe. Please try again."
      redirect_to dt_projects_path
    end
  end
end
