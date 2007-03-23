class PartnerStatusesController < ApplicationController
  # GET /partner_statuses
  # GET /partner_statuses.xml
  def index
    @partner_statuses = PartnerStatus.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @partner_statuses.to_xml }
    end
  end

  # GET /partner_statuses/1
  # GET /partner_statuses/1.xml
  def show
    @partner_status = PartnerStatus.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @partner_status.to_xml }
    end
  end

  # GET /partner_statuses/new
  def new
    @partner_status = PartnerStatus.new
  end

  # GET /partner_statuses/1;edit
  def edit
    @partner_status = PartnerStatus.find(params[:id])
  end

  # POST /partner_statuses
  # POST /partner_statuses.xml
  def create
    @partner_status = PartnerStatus.new(params[:partner_status])

    respond_to do |format|
      if @partner_status.save
        flash[:notice] = 'PartnerStatus was successfully created.'
        format.html { redirect_to partner_status_url(@partner_status) }
        format.xml  { head :created, :location => partner_status_url(@partner_status) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @partner_status.errors.to_xml }
      end
    end
  end

  # PUT /partner_statuses/1
  # PUT /partner_statuses/1.xml
  def update
    @partner_status = PartnerStatus.find(params[:id])

    respond_to do |format|
      if @partner_status.update_attributes(params[:partner_status])
        flash[:notice] = 'PartnerStatus was successfully updated.'
        format.html { redirect_to partner_status_url(@partner_status) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @partner_status.errors.to_xml }
      end
    end
  end

  # DELETE /partner_statuses/1
  # DELETE /partner_statuses/1.xml
  def destroy
    @partner_status = PartnerStatus.find(params[:id])
    @partner_status.destroy

    respond_to do |format|
      format.html { redirect_to partner_statuses_url }
      format.xml  { head :ok }
    end
  end
end
