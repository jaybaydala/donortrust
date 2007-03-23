class VillagesController < ApplicationController
  before_filter :get_data
  
  # GET /villages
  # GET /villages.xml
  def index
    @villages = Village.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @villages.to_xml }
    end
  end

  # GET /villages/1
  # GET /villages/1.xml
  def show
    @village = Village.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @village.to_xml }
    end
  end

  # GET /villages/new
  def new
    @village = Village.new
  end

  # GET /villages/1;edit
  def edit
    @village = Village.find(params[:id])
  end

  # POST /villages
  # POST /villages.xml
  def create
    @village = Village.new(params[:village])

    respond_to do |format|
      if @village.save
        flash[:notice] = 'Village was successfully created.'
        format.html { redirect_to village_url(@village) }
        format.xml  { head :created, :location => village_url(@village) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @village.errors.to_xml }
      end
    end
  end

  # PUT /villages/1
  # PUT /villages/1.xml
  def update
    @village = Village.find(params[:id])

    respond_to do |format|
      if @village.update_attributes(params[:village])
        flash[:notice] = 'Village was successfully updated.'
        format.html { redirect_to village_url(@village) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @village.errors.to_xml }
      end
    end
  end

  # DELETE /villages/1
  # DELETE /villages/1.xml
  def destroy
    @village = Village.find(params[:id])
    @village.destroy

    respond_to do |format|
      format.html { redirect_to villages_url }
      format.xml  { head :ok }
    end
  end
  
   def get_data
    @village_groups = VillageGroup.find(:all)

  end
end
