class ProjectHistoriesController < ApplicationController

  before_filter :get_project

  # GET /projects/1/project_histories
  # GET /projects/1/project_histories.xml
  def index
    @project_histories = @project.project_histories.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @project_histories.to_xml }
    end
  end

  # GET /projects/1/project_histories/1
  # GET /projects/1/project_histories/1.xml
  def show
    @project_history = @project.project_histories.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @project_history.to_xml }
    end
  end

  # GET /projects/1/project_histories/new
  def new
#    @project_history = ProjectHistory.new(:project_id => @project.id, 
#                                          :expected_completion_date => @project.expected_completion_date, 
#                                          :status_id => @project.status_id)
    @project_history = ProjectHistory.new_audit(@project)
  end

  # GET /projects/1/project_histories/1;edit
  def edit
    @project_history = @project.project_histories.find(params[:id])
  end

  # POST /projects/1/project_histories
  # POST /projects/1/project_histories.xml
  def create
    @project_history = ProjectHistory.new(params[:project_history])

    respond_to do |format|
      if (@project.project_histories << @project_history) && @project.save
        flash[:notice] = 'ProjectHistory was successfully created.'
        format.html { redirect_to project_history_url(@project, @project_history) }
        format.xml  { head :created, :location => project_history_url(@project, @project_history) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @project_history.errors.to_xml }
      end
    end
  end

  # PUT /projects/1/project_histories/1
  # PUT /projects/1/project_histories/1.xml
  def update
    @project_history = @project.project_histories.find(params[:id])

    respond_to do |format|
      if @project_history.update_attributes(params[:project_history])
        flash[:notice] = 'ProjectHistory was successfully updated.'
        format.html { redirect_to project_history_url(@project, @project_history) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @project_history.errors.to_xml }
      end
    end
  end
  
  private 
  
  def get_project
    @project = Project.find(params[:project_id])
  end

end
