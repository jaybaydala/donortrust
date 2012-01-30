class Dt::ProjectPoisController < DtApplicationController
 
  def unsubscribe
    @project_poi = ProjectPoi.find_by_token(params[:id])
    if @project_poi
      @project_poi.destroy 
      flash[:notice] = "You have been unsubscribed"
    else
      flash[:notice] = "We couldn't find a matching record to unsubscribe. Please try again."
    end
    redirect_to dt_project_path(@project_poi.project_id)
  end
end
