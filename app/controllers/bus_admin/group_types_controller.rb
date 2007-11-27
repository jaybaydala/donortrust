class BusAdmin::GroupTypesController < ApplicationController
  before_filter :login_required, :check_authorization
  
def index
    @page_title = 'Group Types'
    @groups = GroupType.find(:all)
    respond_to do |format|
      format.html
    end
  end

  def show
    begin
      @group = GroupType.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @page_title = @group.name
    respond_to do |format|
      format.html
    end
  end
  
  def destroy
    @group = GroupType.find(params[:id])
    @group.destroy
    respond_to do |format|
      format.html { redirect_to bus_admin_group_types_url }
      format.xml  { head :ok }
    end
  end
  
  def edit     
    @page_title = "Edit Frequency Details"
    @group = GroupType.find(params[:id])
    respond_to do |format|
      format.html
    end    
  end
  
  def update
    
  @group = GroupType.find(params[:id])
  @saved = @group.update_attributes(params[:group])
    respond_to do |format|
      if @saved
        flash[:notice] = 'Group was successfully updated.'
        format.html { redirect_to bus_admin_group_type_path(@group) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group.errors.to_xml }
      end
    end
  end
  
  def create
    @group = GroupType.new(params[:group])
    Cause.transaction do
      @saved= @group.valid? && @group.save!
      begin
      raise Exception if !@saved
      rescue Exception
      end
    end
    respond_to do |format|
      if @saved
        format.html { redirect_to bus_admin_group_types_url }
        flash[:notice] = 'Group Type was created.'
      else
        format.html { render :action => "new" }
      end
    end
  end  
   
    def get_model
    return GroupType
  end
end
