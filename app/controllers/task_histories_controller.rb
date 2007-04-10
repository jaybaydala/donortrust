class TaskHistoriesController < ApplicationController
  # GET /task_histories
  # GET /task_histories.xml
  def index
    @task_histories = TaskHistory.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @task_histories.to_xml }
    end
  end

  # GET /task_histories/1
  # GET /task_histories/1.xml
  def show
    @task_history = TaskHistory.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @task_history.to_xml }
    end
  end

  # GET /task_histories/new
  def new
    @task_history = TaskHistory.new
  end

  # GET /task_histories/1;edit
  def edit
    @task_history = TaskHistory.find(params[:id])
  end

  # POST /task_histories
  # POST /task_histories.xml
  def create
    @task_history = TaskHistory.new(params[:task_history])

    respond_to do |format|
      if @task_history.save
        flash[:notice] = 'TaskHistory was successfully created.'
        format.html { redirect_to task_history_url(@task_history) }
        format.xml  { head :created, :location => task_history_url(@task_history) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @task_history.errors.to_xml }
      end
    end
  end

  # PUT /task_histories/1
  # PUT /task_histories/1.xml
  def update
    @task_history = TaskHistory.find(params[:id])

    respond_to do |format|
      if @task_history.update_attributes(params[:task_history])
        flash[:notice] = 'TaskHistory was successfully updated.'
        format.html { redirect_to task_history_url(@task_history) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @task_history.errors.to_xml }
      end
    end
  end

  # DELETE /task_histories/1
  # DELETE /task_histories/1.xml
  def destroy
    @task_history = TaskHistory.find(params[:id])
    @task_history.destroy

    respond_to do |format|
      format.html { redirect_to task_histories_url }
      format.xml  { head :ok }
    end
  end
end
