class BusAdmin::PartnersController < ApplicationController
  
  require_role [:partner, :admin, :cfadmin, :superpartner]
  require_role [:admin, :cfadmin, :superpartner], :for => [:manage_users, :add_remove_users, :add_users, :remove_users]
 
  #before_filter :login_required, :check_authorization

  def index
    @page_title = 'Partners'
    if current_busaccount.role_one_of?(:admin, :cfadmin)
      @partners = Partner.find(:all)
    else
      unless current_busaccount.partner.nil?
        @partners = Partner.find(:all, :conditions => ["id = ?", current_busaccount.partner.id])
      else
        @partners = []
      end
    end
    respond_to do |format|
      format.html
    end
  end
  
  def manage_users
    @partner = Partner.find(params[:id])
    #get all users excluding the currently logged in user
    @partner_users = BusAccount.find(:all, :conditions => ["partner_id = ? AND id <> ?", params[:id], current_busaccount.id])
    @non_partner_users = BusAccount.find(:all, :conditions => ["partner_id IS NULL"])
  end
  
  #Add or remove one or more users - uses the name set for the button 
  #to determine which action to take
  def add_remove_users
    @partner = Partner.find(params[:id])
    unless params[:add].nil?
      add_users
    else
      remove_users
    end
    redirect_to manage_users_partner_url
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
  
  private
  
  def add_users
    ActiveRecord::Base.transaction do
        params[:nonusers].each do |nu|
          user = BusAccount.find(nu)
          user.partner = @partner
          user.update
        end
     end
  end
  
  def remove_users
    ActiveRecord::Base.transaction do
        params[:users].each do |u|
          user = BusAccount.find(u)
          user.partner_id = nil
          user.update
        end
     end
  end
  
end


