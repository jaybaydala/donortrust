class BusAdmin::CausesController < ApplicationController
  before_filter :login_required, :check_authorization

 def index
    @page_title = 'Cause'
    @causes = Cause.find(:all)
    respond_to do |format|
      format.html
    end
  end

  def show
    begin
      @cause = Cause.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @page_title = @cause.name
    respond_to do |format|
      format.html
    end
  end
  
  def destroy
    @cause = Cause.find(params[:id])
    @cause.destroy
    respond_to do |format|
      format.html { redirect_to causes_url }
      format.xml  { head :ok }
    end
  end
  
  def edit     
    @page_title = "Edit Cause Details"
    @cause = Cause.find(params[:id])
    respond_to do |format|
      format.html
    end    
  end
  
  def update
    
  @cause = Cause.find(params[:id])
  @saved = @cause.update_attributes(params[:cause])
    respond_to do |format|
      if @saved
        flash[:notice] = 'Cause was successfully updated.'
        format.html { redirect_to cause_path(@cause) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @cause.errors.to_xml }
      end
    end
  end
  
  def create
    @cause = Cause.new(params[:cause])
    Cause.transaction do
      @saved= @cause.valid? && @cause.save!
      begin
      raise Exception if !@saved
      rescue Exception
      end
    end
    respond_to do |format|
      if @saved
        format.html { redirect_to causes_url }
        flash[:notice] = 'Cause was created.'
      else
        format.html { render :action => "new" }
      end
    end
  end
  

end
