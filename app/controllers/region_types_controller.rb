class RegionTypesController < ApplicationController
  # GET /region_types
  # GET /region_types.xml
  def index
    @region_types = RegionType.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @region_types.to_xml }
    end
  end

  # GET /region_types/1
  # GET /region_types/1.xml
  def show
    @region_type = RegionType.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @region_type.to_xml }
    end
  end

  # GET /region_types/new
  def new
    @region_type = RegionType.new
  end

  # GET /region_types/1;edit
  def edit
    @region_type = RegionType.find(params[:id])
  end

  # POST /region_types
  # POST /region_types.xml
  def create
    @region_type = RegionType.new(params[:region_type])

    respond_to do |format|
      if @region_type.save
        flash[:notice] = 'RegionType was successfully created.'
        format.html { redirect_to region_type_url(@region_type) }
        format.xml  { head :created, :location => region_type_url(@region_type) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @region_type.errors.to_xml }
      end
    end
  end

  # PUT /region_types/1
  # PUT /region_types/1.xml
  def update
    @region_type = RegionType.find(params[:id])

    respond_to do |format|
      if @region_type.update_attributes(params[:region_type])
        flash[:notice] = 'RegionType was successfully updated.'
        format.html { redirect_to region_type_url(@region_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @region_type.errors.to_xml }
      end
    end
  end

  # DELETE /region_types/1
  # DELETE /region_types/1.xml
  def destroy
    @region_type = RegionType.find(params[:id])
    @region_type.destroy

    respond_to do |format|
      format.html { redirect_to region_types_url }
      format.xml  { head :ok }
    end
  end
end
