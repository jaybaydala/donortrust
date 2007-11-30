class BusAdmin::PartnerTypesController < ApplicationController
  before_filter :login_required, :check_authorization
  
  include ApplicationHelper  

  def index
    @page_title = 'Partner Types'
    @partners = PartnerType.find(:all)
    respond_to do |format|
      format.html
    end
  end

   def show
    begin
      @partner = PartnerType.find(params[:id])
    rescue ActiveRecord::RecordNotFound
    end
    @page_title = @partner.name
    respond_to do |format|
      format.html
    end
  end
  
  def destroy
    @partner = PartnerType.find(params[:id])
    @partner.destroy
    respond_to do |format|
      format.html { redirect_to bus_admin_partner_types_url }
      format.xml  { head :ok }
    end
  end
  
  def edit     
    @page_title = "Edit Partner Type Details"
    @partner = PartnerType.find(params[:id])
    respond_to do |format|
      format.html
    end    
  end
  
  def update
    
  @partner = PartnerType.find(params[:id])
  @saved = @partner.update_attributes(params[:partner])
    respond_to do |format|
      if @saved
        flash[:notice] = 'Partner Type was successfully updated.'
          
        format.html { redirect_to bus_admin_partner_types_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @partner.errors.to_xml }
      end
    end
  end
  
  def create
    @partner = PartnerType.new(params[:partner])
    Cause.transaction do
      @saved= @partner.valid? && @partner.save!
      begin
      raise Exception if !@saved
      rescue Exception
      end
    end
    respond_to do |format|
      if @saved
        format.html { redirect_to bus_admin_partner_types_url }
        flash[:notice] = 'Partner Type was created.'
      else
        format.html { render :action => "new" }
      end
    end
  end     

  def inactive_records
    @page_title = 'Inactive Partner Types'       
    @partners = PartnerType.find_with_deleted(:all, :conditions => ['deleted_at is not null' ])
    respond_to do |format|
      format.html
    end
  end     
  
  def activate_record
    
    @partner = PartnerType.find_with_deleted(params[:id])
    @partner.deleted_at = nil
    @saved = @partner.update_attributes(params[:partner])
    respond_to do |format|
      if @saved
        flash[:notice] = 'Partner Type was successfully recovered.'
        format.html { redirect_to bus_admin_partner_types_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @partner.errors.to_xml }
      end
    end
  end
  
end