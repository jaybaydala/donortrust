class BusAdmin::QuickFactPartnersController < ApplicationController
 before_filter :login_required, :check_authorization

 def index
    @page_title = 'Quick Fact Partners'
    @quickFacts = QuickFactPartner.find(:all)
    respond_to do |format|
      format.html
    end
  end
  
  def new
    @quickFactPartnerId = params[:quickFactPartnerId]
  end 
  
 def show
    begin
      @quickFacts = QuickFactPartner.find(:all, :conditions => ['partner_id ='+ params[:id].to_s ])
      rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @page_title = "Partner Quick Facts"# @quickFact.quick_fact.name
    respond_to do |format|
      format.html
    end
  end
  
  def destroy
    @quickFact = QuickFactPartner.find(params[:id])
    @quickFact.destroy
    respond_to do |format|
      format.html { redirect_to QuickFactPartner_url }
      format.xml  { head :ok }
    end
  end  
  
    def edit     
    @page_title = "Edit Partner Details"
    @partner = QuickFactPartner.find(params[:id])
    respond_to do |format|
      format.html
    end    
  end
       
  def update

   @quick_fact_partners = QuickFactPartner.find(params[:id])
    @saved = @quick_fact_partners.update_attributes(params[:partner])
    respond_to do |format|
      if @saved
        flash[:notice] = 'Partner was successfully updated.'
        format.html { redirect_to quick_fact_partner_path(@quick_fact_partners.partner_id) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @quick_fact_partners.errors.to_xml }
      end
    end
  end
 
  def create
    @quick_fact_partners = QuickFactPartner.new(params[:quick_fact_partners])
    @quick_fact_partners.partner_id = params[:partner_id]
    Group.transaction do
      partner_saved = @quick_fact_partners.valid? && @quick_fact_partners.save!
      @saved = partner_saved 
      begin
      raise Exception if !@saved
      rescue Exception
      end
    end
    respond_to do |format|
      if @saved
        flash[:notice] = 'Quick Fact was successfully added.'
        format.html { redirect_to quick_fact_partner_path(@quick_fact_partners.partner_id) }
       
      else
        format.html { render :action => "new" }
      end
    end
  end  

end