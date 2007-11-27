class BusAdmin::GroupsController < ApplicationController
  before_filter :login_required, :check_authorization

def index
    @page_title = 'Groups'
    @groups = Group.find(:all)
    respond_to do |format|
      format.html
    end
  end

  def show
    begin
      @group = Group.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @page_title = @group.name
    respond_to do |format|
      format.html
    end
  end
  
  def destroy
    @group = Group.find(params[:id])
    @group.destroy
    respond_to do |format|
      format.html { redirect_to groups_url }
      format.xml  { head :ok }
    end
  end
  
  def edit     
    @page_title = "Edit Frequency Details"
    @group = Group.find(params[:id])
    respond_to do |format|
      format.html
    end    
  end
  
  def update
    
  @group = Group.find(params[:id])
  @saved = @group.update_attributes(params[:group])
    respond_to do |format|
      if @saved
        flash[:notice] = 'Group was successfully updated.'
        format.html { redirect_to group_path(@group) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group.errors.to_xml }
      end
    end
  end
  
  def create
    @group = Group.new(params[:group])
    Cause.transaction do
      @saved= @group.valid? && @group.save!
      begin
      raise Exception if !@saved
      rescue Exception
      end
    end
    respond_to do |format|
      if @saved
        format.html { redirect_to groups_url }
        flash[:notice] = 'Group was created.'
      else
        format.html { render :action => "new" }
      end
    end
  end  


end
