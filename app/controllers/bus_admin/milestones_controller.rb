class BusAdmin::MilestonesController < ApplicationController
  before_filter :login_required

  def list_for_project
    @project = Project.find(params[:id])
  end
  
  def edit
    @milestone = Milestone.find(params[:id])
    @statuses = MilestoneStatus.find(:all)
  end

  def destroy
    begin
      @milestone = Milestone.find(params[:id])
      @success = @milestone.destroy
      if @success
        flash[:notice] = "Successfully deleted the milestone."
      else
        flash[:error] = "An error occurred while attempting to delete the milestone."
      end
      redirect_to bus_admin_list_for_project_milestone_url(@milestone.project)
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
  end
  
  def new
    @milestone = Milestone.new
    @milestone.project_id = params[:id]
    @statuses = MilestoneStatus.find(:all)
  end
  
  def create
    @milestone = Milestone.new(params[:milestone])
    @success = @milestone.save
    if @success
      flash[:notice] = "Successfully saved the milestone."
    else
      flash[:error] = "An error ocurred while saving the milestone."
    end
    redirect_to bus_admin_list_for_project_milestone_url(@milestone.project)
  end
  
  def show
    @milestone = Milestone.find(params[:id])
    @statuses = MilestoneStatus.find(:all)
  end
  
  def update
    begin
      @milestone = Milestone.find(params[:id])
      @success = @milestone.update_attributes(params[:milestone])
      if @success
        flash[:notice] = "Successfully updated the milestone."
      else
        flash[:error] = "An error occurred while attempting to update the milestone."
      end
      redirect_to bus_admin_list_for_project_milestone_url(@milestone.project)
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
  end
end