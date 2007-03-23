class RegionsController < ApplicationController
  before_filter :get_data
  # GET /regions
  # GET /regions.xml
  def index
    @regions = Region.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @regions.to_xml }
    end
  end

  # GET /regions/1
  # GET /regions/1.xml
  def show
    @region = Region.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @region.to_xml }
    end
  end

  # GET /regions/new
  def new
    @region = Region.new
  end

  # GET /regions/1;edit
  def edit
    @region = Region.find(params[:id])
  end

  # POST /regions
  # POST /regions.xml
  def create
    @region = Region.new(params[:region])

    respond_to do |format|
      if @region.save
        flash[:notice] = 'Region was successfully created.'
        format.html { redirect_to region_url(@region) }
        format.xml  { head :created, :location => region_url(@region) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @region.errors.to_xml }
      end
    end
  end

  # PUT /regions/1
  # PUT /regions/1.xml
  def update
    @region = Region.find(params[:id])

    respond_to do |format|
      if @region.update_attributes(params[:region])
        flash[:notice] = 'Region was successfully updated.'
        format.html { redirect_to region_url(@region) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @region.errors.to_xml }
      end
    end
  end

  # DELETE /regions/1
  # DELETE /regions/1.xml
  def destroy
    @region = Region.find(params[:id])
    @region.destroy

    respond_to do |format|
      format.html { redirect_to regions_url }
      format.xml  { head :ok }
    end
  end
  
 def get_data
    @nations = Nation.find(:all)

  end
 end
