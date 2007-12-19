class BusAdmin::TasksController < ApplicationController
 
  before_filter :login_required

  def index
    begin
      @milestone = Milestone.find(params[:milestone_id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    respond_to do |format|
      format.html
    end
  end
  
  def new
    @task = Task.new
    @task.milestone_id = params[:milestone_id]
    respond_to do |format|
      format.html
    end
  end
  
  def create
    @task = Task.new(params[:task])
    @task.milestone_id = params[:milestone_id]
    @success = @task.save
    if @success
      flash[:notice] = "Successfully save the task."
    else
      flash[:error] = "An error occurred while attempting to save the task."
    end
    respond_to do |format|
      format.html { redirect_to( bus_admin_project_milestone_tasks_url(@task.milestone.project, @task.milestone)) }
    end
  end
  
  def edit
    begin
      @task = Task.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    respond_to do |format|
      format.html
    end
  end
  
  def destroy
    begin
      @task = Task.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @success = @task.destroy
    if @success
      flash[:notice] = "Successfully deleted the task."
    else
      flash[:error] = "An error occurred while attempting to delete the task."
    end
    respond_to do |format|
      format.html { redirect_to( bus_admin_project_milestone_tasks_url(@task.milestone.project, @task.milestone)) }
    end
  end

  def show
    begin
      @task = Task.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    respond_to do |format|
      format.html
    end
  end
  
  def update
    begin
      @task = Task.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @success = @task.update_attributes(params[:task])
    if @success
      flash[:notice] = "Successfully updated the task."
    else
      flash[:error] = "An error occurred while attempting to update the task."
    end
    respond_to do |format|
      format.html { redirect_to(bus_admin_project_milestone_tasks_url(@task.milestone.project, @task.milestone)) }
    end
  end
  
end