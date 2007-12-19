class BusAdmin::MilestonesController < ApplicationController
  before_filter :login_required

  def index
    begin
      @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    respond_to do |format|
      format.html
    end
  end
  
  def edit
    begin
      @milestone = Milestone.find(params[:id])
      @statuses = MilestoneStatus.find(:all)
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    respond_to do |format|
      format.html
    end
  end

  def destroy
    begin
      @milestone = Milestone.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end  
    @success = @milestone.destroy
    if @success
      flash[:notice] = "Successfully deleted the milestone."
    else
      flash[:error] = "An error occurred while attempting to delete the milestone."
    end
    respond_to do |format|
      format.html { redirect_to(bus_admin_project_milestones_url(@milestone.project_id)) }
    end
  end
  
  def new
    @milestone = Milestone.new
    @milestone.project_id = params[:project_id]
    @statuses = MilestoneStatus.find(:all)
    respond_to do |format|
      format.html
    end
  end
  
  def create
    @milestone = Milestone.new(params[:milestone])
    @success = @milestone.save
    if @success
      flash[:notice] = "Successfully saved the milestone."
    else
      flash[:error] = "An error ocurred while saving the milestone."
    end
    respond_to do |format|
      format.html { redirect_to(bus_admin_project_milestones_url(@milestone.project_id)) }
    end
  end
  
  def show
    begin
      @milestone = Milestone.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end 
    @statuses = MilestoneStatus.find(:all)
    respond_to do |format|
      format.html
    end
  end
  
  def update
    begin
      @milestone = Milestone.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @success = @milestone.update_attributes(params[:milestone])
    if @success
      flash[:notice] = "Successfully updated the milestone."
    else
      flash[:error] = "An error occurred while attempting to update the milestone."
    end
    respond_to do |format|
      format.html { redirect_to(bus_admin_project_milestones_url(@milestone.project_id)) }
    end
  end
end