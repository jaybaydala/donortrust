class TaskStatusesController < ApplicationController
  # GET /task_statuses
  # GET /task_statuses.xml
  def index
    @task_statuses = TaskStatus.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @task_statuses.to_xml }
    end
  end

  # GET /task_statuses/1
  # GET /task_statuses/1.xml
  def show
    @task_status = TaskStatus.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @task_status.to_xml }
    end
  end

  # GET /task_statuses/new
  def new
    @task_status = TaskStatus.new
  end

  # GET /task_statuses/1;edit
  def edit
    @task_status = TaskStatus.find(params[:id])
  end

  # POST /task_statuses
  # POST /task_statuses.xml
  def create
    @task_status = TaskStatus.new(params[:task_status])

    respond_to do |format|
      if @task_status.save
        flash[:notice] = 'TaskStatus was successfully created.'
        format.html { redirect_to task_status_url(@task_status) }
        format.xml  { head :created, :location => task_status_url(@task_status) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @task_status.errors.to_xml }
      end
    end
  end

  # PUT /task_statuses/1
  # PUT /task_statuses/1.xml
  def update
    @task_status = TaskStatus.find(params[:id])

    respond_to do |format|
      if @task_status.update_attributes(params[:task_status])
        flash[:notice] = 'TaskStatus was successfully updated.'
        format.html { redirect_to task_status_url(@task_status) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @task_status.errors.to_xml }
      end
    end
  end

  # DELETE /task_statuses/1
  # DELETE /task_statuses/1.xml
  def destroy
    @task_status = TaskStatus.find(params[:id])
    @task_status.destroy

    respond_to do |format|
      format.html { redirect_to task_statuses_url }
      format.xml  { head :ok }
    end
  end
end
