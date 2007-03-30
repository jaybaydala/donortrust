class MilestoneStatusesController < ApplicationController
  # GET /milestone_statuses
  # GET /milestone_statuses.xml
  def index
    @milestone_statuses = MilestoneStatus.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @milestone_statuses.to_xml }
    end
  end

  # GET /milestone_statuses/1
  # GET /milestone_statuses/1.xml
  def show
    @milestone_status = MilestoneStatus.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @milestone_status.to_xml }
    end
  end

  # GET /milestone_statuses/new
  def new
    @milestone_status = MilestoneStatus.new
  end

  # GET /milestone_statuses/1;edit
  def edit
    @milestone_status = MilestoneStatus.find(params[:id])
  end

  # POST /milestone_statuses
  # POST /milestone_statuses.xml
  def create
    @milestone_status = MilestoneStatus.new(params[:milestone_status])

    respond_to do |format|
      if @milestone_status.save
        flash[:notice] = 'MilestoneStatus was successfully created.'
        format.html { redirect_to milestone_status_url(@milestone_status) }
        format.xml  { head :created, :location => milestone_status_url(@milestone_status) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @milestone_status.errors.to_xml }
      end
    end
  end

  # PUT /milestone_statuses/1
  # PUT /milestone_statuses/1.xml
  def update
    @milestone_status = MilestoneStatus.find(params[:id])

    respond_to do |format|
      if @milestone_status.update_attributes(params[:milestone_status])
        flash[:notice] = 'MilestoneStatus was successfully updated.'
        format.html { redirect_to milestone_status_url(@milestone_status) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @milestone_status.errors.to_xml }
      end
    end
  end

  # DELETE /milestone_statuses/1
  # DELETE /milestone_statuses/1.xml
  def destroy
    @milestone_status = MilestoneStatus.find(params[:id])
    @milestone_status.destroy

    respond_to do |format|
      format.html { redirect_to milestone_statuses_url }
      format.xml  { head :ok }
    end
  end
end
