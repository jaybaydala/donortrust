class BusAdmin::RanksController < ApplicationController
 
 before_filter :login_required
 require_role [:cfadmin, :admin], :only => [:new, :edit, :destroy, :update, :create]
  
  def index
    begin
      @project = Project.find(params[:project_id])
     rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @rank_types = RankType.find(:all)
    @rank_values = RankValue.find(:all)
    respond_to do |format|
      format.html
    end
  end
  
  def new
    @rank = Rank.new
    @rank.project_id = params[:project_id]
    @rank_types = RankType.find(:all)
    @rank_values = RankValue.find(:all)
    respond_to do |format|
      format.html
    end
  end
  
  def create
    @rank = Rank.new(params[:rank])
    @rank.project_id = params[:project_id]
    @success = @rank.save
    if @success
      flash[:notice] = "Successfully saved the rank."
      respond_to do |format|
        format.html { redirect_to(bus_admin_project_ranks_url(@rank.project_id))}
      end
    else
      flash[:error] = "An error occurred while attempting to save the rank."
      respond_to do |format|
        format.html { redirect_to(bus_admin_project_new_rank_url(@rank.project_id))}
      end
    end
    
  end
  
  def edit
    begin
      @rank = Rank.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @rank_types = RankType.find(:all)
    @rank_values = RankValue.find(:all)
    respond_to do |format|
      format.html
    end
  end
  
  def update
    begin
      @rank = Rank.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @success = @rank.update_attributes(params[:rank])
    if @success
      flash[:notice] = "Successfully updated the rank."
      respond_to do |format|
        format.html { redirect_to(bus_admin_project_ranks_url(@rank.project_id))}
      end
    else
      flash[:error] = "An error occurred while attempting to update the rank."
      respond_to do |format|
        format.html { redirect_to(bus_admin_project_edit_rank_url(@rank.project_id, @rank))}
      end
    end
    
  end
  
  def destroy
    begin
      @rank = Rank.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @success = @rank.destroy
    if @success
      flash[:notice] = "Successfully deleted the rank."
    else
      flash[:error] = "An error occurred while attempting to delete the rank."
    end
    respond_to do |format|
      format.html { redirect_to(bus_admin_project_ranks_url(@rank.project_id))}
    end
  end
end
