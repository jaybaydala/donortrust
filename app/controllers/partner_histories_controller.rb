class PartnerHistoriesController < ApplicationController
  before_filter :get_data

  # GET /partner_histories
  # GET /partner_histories.xml
  def index
    @partner_histories = PartnerHistory.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @partner_histories.to_xml }
    end
  end

  # GET /partner_histories/1
  # GET /partner_histories/1.xml
  def show
    @partner_history = PartnerHistory.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @partner_history.to_xml }
    end
  end

  # GET /partner_histories/new
  def new
    @partner_history = PartnerHistory.new_audit (@partner)
  end

  # GET /partner_histories/1;edit
#  def edit
#    @partner_history = PartnerHistory.find(params[:id])
#  end

  # POST /partner_histories
  # POST /partner_histories.xml
  def create
    @partner_history = PartnerHistory.new(params[:partner_history])

    respond_to do |format|
      if @partner_history.save_audit (@partner)
        flash[:notice] = 'PartnerHistory was successfully created.'
        format.html { redirect_to partner_url(@partner) }
        format.xml  { head :created, :location => partner_url(@partner) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @partner_history.errors.to_xml }
      end
    end
  end

  # PUT /partner_histories/1
  # PUT /partner_histories/1.xml
#  def update
#    @partner_history = PartnerHistory.find(params[:id])
#
#    respond_to do |format|
#      if @partner_history.update_attributes(params[:partner_history])
#        flash[:notice] = 'PartnerHistory was successfully updated.'
#        format.html { redirect_to partner_history_url(@partner_history) }
#        format.xml  { head :ok }
#      else
#        format.html { render :action => "edit" }
#        format.xml  { render :xml => @partner_history.errors.to_xml }
#      end
#    end
#  end

  # DELETE /partner_histories/1
  # DELETE /partner_histories/1.xml
#  def destroy
#    @partner_history = @partner 
#    #PartnerHistory.find(params[:id])
#    @partner_history.destroy
#
#    respond_to do |format|
#      format.html { redirect_to partner_histories_url }
#      format.xml  { head :ok }
#    end
#  end
  
  private
  def get_data
    @partner = Partner.find(params[:partner_id]) if params[:partner_id]
    @partnerTypes = PartnerType.find(:all)
    @partnerStatuses = PartnerStatus.find(:all)
  end
end
