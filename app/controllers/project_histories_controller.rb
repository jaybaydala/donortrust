class ProjectHistoriesController < ApplicationController

  # GET /project_histories
  # GET /project_histories.xml
  def index
    @project_histories = Project.find(params[:project_id]).project_histories.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @project_histories.to_xml }
    end
  end

  # GET /project_histories/1
  # GET /project_histories/1.xml
  def show
    @project_history = Project.find(params[:project_id]).project_histories.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @project_history.to_xml }
    end
  end

  # GET /project_histories/new
  def new
    @project_history = ProjectHistory.new
  end

  # GET /project_histories/1;edit
  def edit
    @project_history = Project.find(params[:project_id]).project_histories.find(params[:id])
  end

  # POST /project_histories
  # POST /project_histories.xml
  def create
    @project = Project.find(params[:project_id])
    @project_history = ProjectHistory.new(params[:project_history])

    respond_to do |format|
      if (@project.project_histories << @project_history) && @project.save
        flash[:notice] = 'ProjectHistory was successfully created.'
        format.html { redirect_to project_history_url(@project_history, :project_id => @project.id) }
        format.xml  { head :created, :location => project_history_url(@project_history, :project_id => @project.id) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @project_history.errors.to_xml }
      end
    end
  end

  # PUT /project_histories/1
  # PUT /project_histories/1.xml
  def update
    @project_history = Project.find(params[:project_id]).project_histories.find(params[:id])

    respond_to do |format|
      if @project_history.update_attributes(params[:project_history])
        flash[:notice] = 'ProjectHistory was successfully updated.'
        format.html { redirect_to project_history_url(@project_history, :project_id => @project_history.project_id) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @project_history.errors.to_xml }
      end
    end
  end

end
