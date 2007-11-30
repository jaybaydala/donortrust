class BusAdmin::FrequencyTypesController < ApplicationController
 before_filter :login_required, :check_authorization


 def index
    @page_title = 'Frequency'
    @frequencys = FrequencyType.find(:all)
    respond_to do |format|
      format.html
    end
  end

  def show
    begin
      @frequency = FrequencyType.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @page_title = @frequency.name
    respond_to do |format|
      format.html
    end
  end
  
  def destroy
    @frequency = FrequencyType.find(params[:id])
    @frequency.destroy
    respond_to do |format|
      format.html { redirect_to bus_admin_frequency_types_url }
      format.xml  { head :ok }
    end
  end
  
  def edit     
    @page_title = "Edit Frequency Details"
    @frequency = FrequencyType.find(params[:id])
    respond_to do |format|
      format.html
    end    
  end
  
  def update
    
  @frequency = FrequencyType.find(params[:id])
  @saved = @frequency.update_attributes(params[:frequency])
    respond_to do |format|
      if @saved
        flash[:notice] = 'Frequency was successfully updated.'
        format.html { redirect_to bus_admin_frequency_type_path(@frequency) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @frequency.errors.to_xml }
      end
    end
  end
  
  def create
    @frequency = FrequencyType.new(params[:frequency])
    Cause.transaction do
      @saved= @frequency.valid? && @frequency.save!
      begin
      raise Exception if !@saved
      rescue Exception
      end
    end
    respond_to do |format|
      if @saved
        format.html { redirect_to bus_admin_frequency_types_url }
        flash[:notice] = 'Frequency Type was created.'
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  def inactive_records
    @page_title = 'Inactive Frequency Types'
       
    @frequencys = FrequencyType.find_with_deleted(:all, :conditions => ['deleted_at is not null' ])
    respond_to do |format|
      format.html
    end
  end     
  
  def activate_record
    
    @frequency = FrequencyType.find_with_deleted(params[:id])
    @frequency.deleted_at = nil
    @saved = @frequency.update_attributes(params[:frequency])
    respond_to do |format|
      if @saved
        flash[:notice] = 'Frequency type  was successfully recovered.'
        format.html { redirect_to bus_admin_frequency_types_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @frequency.errors.to_xml }
      end
    end
  end
  
end
