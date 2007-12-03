class BusAdmin::MeasuresController < ApplicationController
  
   def index
    @page_title = 'Measures'
    @measures = Measure.find(:all)
    respond_to do |format|
      format.html
    end
  end  
  
  def show
    begin
      @measure = Measure.find(params[:id])
#    rescue ActiveRecord::RecordNotFound
#      rescue_404 and return
    end
    @page_title = @measure.description
    respond_to do |format|
      format.html
    end
  end

  
  def destroy
    @measure = Measure.find(params[:id])
    @measure.destroy
    respond_to do |format|
      format.html { redirect_to  measures_url }
      format.xml  { head :ok }
    end
  end
  
  def edit     
    @page_title = "Edit Measure Details"
    @measure = Measure.find(params[:id])
    respond_to do |format|
      format.html
    end    
  end
  
  def update
    
  @measure = Measure.find(params[:id])
  @saved = @measure.update_attributes(params[:measure])
    respond_to do |format|
      if @saved
        flash[:notice] = 'Measure was successfully updated.'
          
        format.html { redirect_to measures_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @measure.errors.to_xml }
      end
    end
  end
  
  def create
    @measure = Measure.new(params[:measure])
    Cause.transaction do
      @saved= @measure.valid? && @measure.save!
      begin
      raise Exception if !@saved
      rescue Exception
      end
    end
    respond_to do |format|
      if @saved
        format.html { redirect_to measures_url }
        flash[:notice] = 'Measure was created.'
      else
        format.html { render :action => "new" }
      end
    end
  end  
  
  def inactive_records
    @page_title = 'Inactive Measures'       
    @measures = Measure.find_with_deleted(:all, :conditions => ['deleted_at is not null' ])
    respond_to do |format|
      format.html
    end
  end     
  
  def activate_record    
    @measure = Measure.find_with_deleted(params[:id])
    @measure.deleted_at = nil
    @saved = @measure.update_attributes(params[:measure])
    respond_to do |format|
      if @saved
        flash[:notice] = 'Measure was successfully recovered.'
        format.html { redirect_to measures_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @measure.errors.to_xml }
      end
    end
  end
  
end
