class BusAdmin::SectorsController < ApplicationController
 # before_filter :login_required, :check_authorization

  def index
    @page_title = 'Sectors'
    @sectors = Sector.find(:all)
    respond_to do |format|
      format.html
    end
  end

   def show
    begin
      @sector = Sector.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @page_title = @sector.name
    respond_to do |format|
      format.html
    end
  end
  
  def destroy
    @sector = Sector.find(params[:id])
    @sector.destroy
    respond_to do |format|
      format.html { redirect_to sectors_url }
      format.xml  { head :ok }
    end
  end
  
  def edit     
    @page_title = "Edit Sector Details"
    @sector = Sector.find(params[:id])
    respond_to do |format|
      format.html
    end    
  end
  
  def update    
  @sector = Sector.find(params[:id])
  @saved = @sector.update_attributes(params[:sector])
    respond_to do |format|
      if @saved
        flash[:notice] = 'Sector was successfully updated.'
        format.html { redirect_to sector_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sector.errors.to_xml }
      end
    end
  end
  
  def create
    @sector = Sector.new(params[:sector])
    Cause.transaction do
      @saved= @sector.valid? && @sector.save!
      begin
      raise Exception if !@saved
      rescue Exception
      end
    end
    respond_to do |format|
      if @saved
        format.html { redirect_to sectors_url }
        flash[:notice] = 'Sector was created.'
      else
        format.html { render :action => "new" }
      end
    end
  end     
  
  def inactive_records
    @page_title = 'Inactive Sectors'
       
    @sectors = Sector.find_with_deleted(:all, :conditions => ['deleted_at is not null' ])
    respond_to do |format|
      format.html
    end
  end     
  
  def activate_record
    
    @sector = Sector.find_with_deleted(params[:id])
    @sector.deleted_at = nil
    @saved = @sector.update_attributes(params[:sector])
    respond_to do |format|
      if @saved
        flash[:notice] = 'Sector was successfully recovered.'
        format.html { redirect_to sectors_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sector.errors.to_xml }
      end
    end
  end
  
end
