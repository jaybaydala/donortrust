class ProjectStatusesController < ApplicationController
  # GET /project_statuses
  # GET /project_statuses.xml
  def index
    @project_statuses = ProjectStatus.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @project_statuses.to_xml }
    end
  end

  # GET /project_statuses/1
  # GET /project_statuses/1.xml
  def show
    @project_status = ProjectStatus.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @project_status.to_xml }
    end
  end

  # GET /project_statuses/new
  def new
    @project_status = ProjectStatus.new
  end

  # GET /project_statuses/1;edit
  def edit
    @project_status = ProjectStatus.find(params[:id])
  end

  # POST /project_statuses
  # POST /project_statuses.xml
  def create
    @project_status = ProjectStatus.new(params[:project_status])

    respond_to do |format|
      if @project_status.save
        flash[:notice] = 'ProjectStatus was successfully created.'
        format.html { redirect_to project_status_url(@project_status) }
        format.xml  { head :created, :location => project_status_url(@project_status) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @project_status.errors.to_xml }
      end
    end
  end

  # PUT /project_statuses/1
  # PUT /project_statuses/1.xml
  def update
    @project_status = ProjectStatus.find(params[:id])

    respond_to do |format|
      if @project_status.update_attributes(params[:project_status])
        flash[:notice] = 'ProjectStatus was successfully updated.'
        format.html { redirect_to project_status_url(@project_status) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @project_status.errors.to_xml }
      end
    end
  end

  # DELETE /project_statuses/1
  # DELETE /project_statuses/1.xml
  def destroy
    @project_status = ProjectStatus.find(params[:id])
    @project_status.destroy

    respond_to do |format|
      format.html { redirect_to project_statuses_url }
      format.xml  { head :ok }
    end
  end
end
