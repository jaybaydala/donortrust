class BusAdmin::PartnersController < ApplicationController
    
 # before_filter :login_required, :check_authorization

  def index
    @page_title = 'Partners'
    @partners = Partner.find(:all)
    respond_to do |format|
      format.html
    end
  end
  
  def new

  end
  
  def show
    begin
      @partner = Partner.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @page_title = @partner.name
    respond_to do |format|
      format.html
    end
  end
  
  def destroy
    @partner = Partner.find(params[:id])
    @partner.destroy
    respond_to do |format|
      format.html { redirect_to partners_url }
      format.xml  { head :ok }
    end
  end
  
  def edit     
    @page_title = "Edit Partner Details"
    @partner = Partner.find(params[:id])
    respond_to do |format|
      format.html
    end    
  end
  
  def update
    
  @partner = Partner.find(params[:id])
  @saved = @partner.update_attributes(params[:partner])
    respond_to do |format|
      if @saved
        flash[:notice] = 'Partner was successfully updated.'
        format.html { redirect_to partner_path(@partner) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @partner.errors.to_xml }
      end
    end
  end
  
  def create
    @partner = Partner.new(params[:partner])
    Partner.transaction do
      @saved= @partner.valid? && @partner.save!
      begin
      raise Exception if !@saved
      rescue Exception
      end
    end
    respond_to do |format|
      if @saved
        format.html { redirect_to partners_url }
        flash[:notice] = 'Partner was created.'
      else
        format.html { render :action => "new" }
      end
    end
  end
  
end


