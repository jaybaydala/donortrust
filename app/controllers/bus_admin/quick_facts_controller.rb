class BusAdmin::QuickFactsController < ApplicationController
before_filter :login_required, :check_authorization

  def index
    @page_title = 'Quick Facts'
    @quickFacts = QuickFact.find(:all)
    respond_to do |format|
      format.html
    end
  end
  
  def update
   @quickFact = QuickFact.find(params[:id])
    @saved = @quickFact.update_attributes(params[:type])
    respond_to do |format|
      if @saved
        flash[:notice] = 'Quick Fact was successfully updated.'
        format.html { redirect_to quick_fact_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @quickFact.errors.to_xml }
      end
    end
  end
  
  def show
    begin
      @quickFacts = QuickFact.find(:all)
      rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @page_title = "Quick Facts"
    respond_to do |format|
      format.html
    end
  end

  def edit     
    @page_title = "Edit Quick Fact"
    @quickFact = QuickFact.find(params[:id])
    respond_to do |format|
      format.html
    end    
  end
  
   def create
    @quickFact = QuickFact.new(params[:quick_facts])
    @quickFact.quick_fact_type_id = 1
    QuickFact.transaction do
    begin
      raise Exception if !@saved
      rescue Exception
      end
    end
    respond_to do |format|
      if @saved
        format.html { redirect_to quick_facts_url }
        flash[:notice] = 'Quick Fact was created.'
      else
        format.html { render :action => "new" }
      end
    end
  end
  
end