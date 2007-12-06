class BusAdmin::PartnerStatusesController < ApplicationController
 # before_filter :login_required, :check_authorization

  include ApplicationHelper
  
  def index
    @page_title = 'Partner Status'
    @partners = PartnerStatus.find(:all)
    respond_to do |format|
      format.html
    end
  end

   def show
    begin
      @partner = PartnerStatus.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @page_title = @partner.name
    respond_to do |format|
      format.html
    end
  end
  
  def destroy
    @partner = PartnerStatus.find(params[:id])
    @partner.destroy
    respond_to do |format|
      format.html { redirect_to bus_admin_partner_statuses_url }
      format.xml  { head :ok }
    end
  end
  
  def edit     
    @page_title = "Edit Partner Status Details"
    @partner = PartnerStatus.find(params[:id])
    respond_to do |format|
      format.html
    end    
  end
  
  def update
    
  @partner = PartnerStatus.find(params[:id])
  @saved = @partner.update_attributes(params[:partner])
    respond_to do |format|
      if @saved
        flash[:notice] = 'Partner Status was successfully updated.'
          
        format.html { redirect_to bus_admin_partner_statuses_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @partner.errors.to_xml }
      end
    end
  end
  
  def create
    @partner = PartnerStatus.new(params[:partner])
    Cause.transaction do
      @saved= @partner.valid? && @partner.save!
      begin
      raise Exception if !@saved
      rescue Exception
      end
    end
    respond_to do |format|
      if @saved
        format.html { redirect_to bus_admin_partner_statuses_url }
        flash[:notice] = 'Partner Status was created.'
      else
        format.html { render :action => "new" }
      end
    end
  end     
  
  def inactive_records
    @page_title = 'Inactive Partner Status'       
    @partners = PartnerStatus.find_with_deleted(:all, :conditions => ['deleted_at is not null' ])
    respond_to do |format|
      format.html
    end
  end     
  
  def activate_record
    
    @partner = PartnerStatus.find_with_deleted(params[:id])
    @partner.deleted_at = nil
    @saved = @partner.update_attributes(params[:partner])
    respond_to do |format|
      if @saved
        flash[:notice] = 'Partner Status was successfully recovered.'
        format.html { redirect_to bus_admin_partner_statuses_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @partner.errors.to_xml }
      end
    end
  end
  
end


