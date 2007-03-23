class VillageGroupsController < ApplicationController
 before_filter :get_data
 
  # GET /village_groups
  # GET /village_groups.xml
  def index
    @village_groups = VillageGroup.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @village_groups.to_xml }
    end
  end

  # GET /village_groups/1
  # GET /village_groups/1.xml
  def show
    @village_group = VillageGroup.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @village_group.to_xml }
    end
  end

  # GET /village_groups/new
  def new
    @village_group = VillageGroup.new
  end

  # GET /village_groups/1;edit
  def edit
    @village_group = VillageGroup.find(params[:id])
  end

  # POST /village_groups
  # POST /village_groups.xml
  def create
    @village_group = VillageGroup.new(params[:village_group])

    respond_to do |format|
      if @village_group.save
        flash[:notice] = 'VillageGroup was successfully created.'
        format.html { redirect_to village_group_url(@village_group) }
        format.xml  { head :created, :location => village_group_url(@village_group) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @village_group.errors.to_xml }
      end
    end
  end

  # PUT /village_groups/1
  # PUT /village_groups/1.xml
  def update
    @village_group = VillageGroup.find(params[:id])

    respond_to do |format|
      if @village_group.update_attributes(params[:village_group])
        flash[:notice] = 'VillageGroup was successfully updated.'
        format.html { redirect_to village_group_url(@village_group) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @village_group.errors.to_xml }
      end
    end
  end

  # DELETE /village_groups/1
  # DELETE /village_groups/1.xml
  def destroy
    @village_group = VillageGroup.find(params[:id])
    @village_group.destroy

    respond_to do |format|
      format.html { redirect_to village_groups_url }
      format.xml  { head :ok }
    end
  end
  
   def get_data
    @regions = Region.find(:all)

  end
end
