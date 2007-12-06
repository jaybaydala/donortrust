class BusAdmin::ProjectStatusesController < ApplicationController
 # before_filter :login_required, :check_authorization
  
  include ApplicationHelper
  
  def index
    @page_title = 'Project Status'
    @projects = ProjectStatus.find(:all)
    respond_to do |format|
      format.html
    end
  end

   def show
    begin
      @project = ProjectStatus.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @page_title = @project.name
    respond_to do |format|
      format.html
    end
  end
  
  def destroy
    @project = ProjectStatus.find(params[:id])
    @project.destroy
    respond_to do |format|
      format.html { redirect_to bus_admin_project_statuses_url }
      format.xml  { head :ok }
    end
  end
  
  def edit     
    @page_title = "Edit Project Status Details"
    @project = ProjectStatus.find(params[:id])
    respond_to do |format|
      format.html
    end    
  end
  
  def update
    
  @project = ProjectStatus.find(params[:id])
  @saved = @project.update_attributes(params[:project])
    respond_to do |format|
      if @saved
        flash[:notice] = 'Project Status was successfully updated.'
          
        format.html { redirect_to bus_admin_project_statuses_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @project.errors.to_xml }
      end
    end
  end
  
  def create
    @project = ProjectStatus.new(params[:project])
    Cause.transaction do
      @saved= @project.valid? && @project.save!
      begin
      raise Exception if !@saved
      rescue Exception
      end
    end
    respond_to do |format|
      if @saved
        format.html { redirect_to bus_admin_project_statuses_url }
        flash[:notice] = 'Project Status was created.'
      else
        format.html { render :action => "new" }
      end
    end
  end     
  
  def inactive_records
    @page_title = 'Inactive Project Status'
       
    @projects = ProjectStatus.find_with_deleted(:all, :conditions => ['deleted_at is not null' ])
    respond_to do |format|
      format.html
    end
  end     
  
  def activate_record
    
    @project = ProjectStatus.find_with_deleted(params[:id])
    @project.deleted_at = nil
    @saved = @project.update_attributes(params[:project])
    respond_to do |format|
      if @saved
        flash[:notice] = 'Project Status was successfully recovered.'
        format.html { redirect_to bus_admin_project_statuses_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @project.errors.to_xml }
      end
    end
  end
  
end



