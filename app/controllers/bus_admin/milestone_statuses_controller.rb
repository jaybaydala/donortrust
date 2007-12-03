class BusAdmin::MilestoneStatusesController < ApplicationController
  before_filter :login_required, :check_authorization
  include ApplicationHelper

  def index
    @page_title = 'Milestone Statuses'
    @milestones = MilestoneStatus.find(:all)
    respond_to do |format|
      format.html
    end
  end
  
  def show
    begin
      @milestone = MilestoneStatus.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @page_title = @milestone.name
    respond_to do |format|
      format.html
    end
  end
  
  def destroy
    @milestone = MilestoneStatus.find(params[:id])
    @milestone.destroy
    respond_to do |format|
      format.html { redirect_to  bus_admin_milestone_statuses_url }
      format.xml  { head :ok }
    end
  end
  
  def edit     
    @page_title = "Edit Milestone Status Details"
    @milestone = MilestoneStatus.find(params[:id])
    respond_to do |format|
      format.html
    end    
  end
  
  def update
    
  @milestone = MilestoneStatus.find(params[:id])
  @saved = @milestone.update_attributes(params[:milestone])
    respond_to do |format|
      if @saved
        flash[:notice] = 'Milestone Status was successfully updated.'
          
        format.html { redirect_to bus_admin_milestone_statuses_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @milestone.errors.to_xml }
      end
    end
  end
  
  def create
    @milestone = MilestoneStatus.new(params[:milestone])
    Cause.transaction do
      @saved= @milestone.valid? && @milestone.save!
      begin
      raise Exception if !@saved
      rescue Exception
      end
    end
    respond_to do |format|
      if @saved
        format.html { redirect_to bus_admin_milestone_statuses_url }
        flash[:notice] = 'Milestone Status was created.'
      else
        format.html { render :action => "new" }
      end
    end
  end 
  
  def inactive_records
    @page_title = 'Inactive MilestoneStatuses'
       
    @milestones = MilestoneStatus.find_with_deleted(:all, :conditions => ['deleted_at is not null' ])
    respond_to do |format|
      format.html
    end
  end     
  
  def activate_record    
    @milestone = MilestoneStatus.find_with_deleted(params[:id])
    @milestone.deleted_at = nil
    @saved = @milestone.update_attributes(params[:milestone])
    respond_to do |format|
      if @saved
        flash[:notice] = 'Milestone Status was successfully recovered.'
        format.html { redirect_to bus_admin_milestone_statuses_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @milestone.errors.to_xml }
      end
    end
  end
    
end
