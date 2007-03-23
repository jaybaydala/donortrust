class PartnerTypesController < ApplicationController
  # GET /partner_types
  # GET /partner_types.xml
  def index
    @partner_types = PartnerType.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @partner_types.to_xml }
    end
  end

  # GET /partner_types/1
  # GET /partner_types/1.xml
  def show
    @partner_type = PartnerType.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @partner_type.to_xml }
    end
  end

  # GET /partner_types/new
  def new
    @partner_type = PartnerType.new
  end

  # GET /partner_types/1;edit
  def edit
    @partner_type = PartnerType.find(params[:id])
  end

  # POST /partner_types
  # POST /partner_types.xml
  def create
    @partner_type = PartnerType.new(params[:partner_type])

    respond_to do |format|
      if @partner_type.save
        flash[:notice] = 'PartnerType was successfully created.'
        format.html { redirect_to partner_type_url(@partner_type) }
        format.xml  { head :created, :location => partner_type_url(@partner_type) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @partner_type.errors.to_xml }
      end
    end
  end

  # PUT /partner_types/1
  # PUT /partner_types/1.xml
  def update
    @partner_type = PartnerType.find(params[:id])

    respond_to do |format|
      if @partner_type.update_attributes(params[:partner_type])
        flash[:notice] = 'PartnerType was successfully updated.'
        format.html { redirect_to partner_type_url(@partner_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @partner_type.errors.to_xml }
      end
    end
  end

  # DELETE /partner_types/1
  # DELETE /partner_types/1.xml
  def destroy
    @partner_type = PartnerType.find(params[:id])
    @partner_type.destroy

    respond_to do |format|
      format.html { redirect_to partner_types_url }
      format.xml  { head :ok }
    end
  end
end
