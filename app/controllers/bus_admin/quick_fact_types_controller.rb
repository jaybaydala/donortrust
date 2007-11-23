class BusAdmin::QuickFactTypesController < ApplicationController
  before_filter :login_required, :check_authorization
  
 def index
    @page_title = 'Quick Fact Types'
    @quickFacts = QuickFactType.find(:all)
    respond_to do |format|
      format.html
    end
  end

  def create
    @type = QuickFactType.new(params[:quick_fact_types])
    QuickFactType.transaction do
      @saved= @type.valid? && @type.save!
      begin
        raise Exception if !@saved
        rescue Exception
      end
    end
    respond_to do |format|
      if @saved       
        format.html { redirect_to quick_fact_types_url }
        flash[:notice] = 'Type was created.'
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  def edit     
    @page_title = "Edit Quick Fact Type"
    @type = QuickFactType.find(params[:id])
    respond_to do |format|
      format.html
    end    
  end
  
  def update
   @types = QuickFactType.find(params[:id])
    @saved = @types.update_attributes(params[:type])
    respond_to do |format|
      if @saved
        flash[:notice] = 'Type was successfully updated.'
        format.html { redirect_to quick_fact_type_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @types.errors.to_xml }
      end
    end
  end
  
   def show
    begin
      @quickFacts = QuickFactType.find(:all)
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @page_title = "Quick Fact Types"
    respond_to do |format|
      format.html
    end
  end
  
  def destroy
    @type = QuickFactType.find(params[:id])
    @type.destroy
    respond_to do |format|
      format.html { redirect_to quick_fact_types_url }
      format.xml  { head :ok }
    end
  end  
  
end
