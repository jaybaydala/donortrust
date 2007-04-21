class PartnersController < ApplicationController
  before_filter :get_data

  # GET /partners
  # GET /partners.xml
  def index
    @partners = Partner.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @partners.to_xml }
    end
  end

  # GET /partners/1
  # GET /partners/1.xml
  def show
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @partner.to_xml }
    end
  end

  # GET /partners/new
  def new
    @partner = Partner.new
  end

  # GET /partners/1;edit
  def edit
    #@partner = Partner.find(params[:id])
    redirect_to new_partner_history_path(@partner)
  end

  # POST /partners
  # POST /partners.xml
  def create
    @partner = Partner.new(params[:partner])

    respond_to do |format|
      if @partner.save_with_audit
        flash[:notice] = 'Partner was successfully created.'
        format.html { redirect_to partner_url(@partner) }
        format.xml  { head :created, :location => partner_url(@partner) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @partner.errors.to_xml }
      end
    end
  end

  # PUT /partners/1
  # PUT /partners/1.xml
#  def update
#    respond_to do |format|
#      if @partner.update_attributes(params[:partner])
#        flash[:notice] = 'Partner was successfully updated.'
#        format.html { redirect_to partner_url(@partner) }
#        format.xml  { head :ok }
#      else
#        format.html { render :action => "edit" }
#        format.xml  { render :xml => @partner.errors.to_xml }
#      end
#    end
#  end

  # DELETE /partners/1
  # DELETE /partners/1.xml
  def destroy
    @partner.destroy

    respond_to do |format|
      format.html { redirect_to partners_url }
      format.xml  { head :ok }
    end
  end
  
  def get_data
    @partnerTypes = PartnerType.find(:all)
    @partnerStatuses = PartnerStatus.find(:all)
    @partner = Partner.find(params[:id]) if params[:id] 
  end
end
