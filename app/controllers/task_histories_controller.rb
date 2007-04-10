class TaskHistoriesController < ApplicationController
  before_filter( :get_task )

  # GET /task/{:task_id}/task_histories
  # GET /task/{:task_id}/task_histories.xml
  def index
    @task_histories = @task.task_histories

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @task_histories.to_xml }
    end
  end

  # GET /task/{:task_id}/task_histories/1
  # GET /task/{:task_id}/task_histories/1.xml
  def show
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @task_history.to_xml }
    end
  end

  # GET /task/{:task_id}/task_histories/new
  def new
    @task_history = TaskHistory.new
  end

  # GET /task/{:task_id}/task_histories/1;edit
  def edit
  end

  # POST /task/{:task_id}/task_histories
  # POST /task/{:task_id}/task_histories.xml
  def create
    @task_history = TaskHistory.new( params[ :task_history ])
    @task_history.task_id = params[ :task_id ]

    respond_to do |format|
      if @task_history.save
        flash[:notice] = 'TaskHistory was successfully created.'
        format.html { redirect_to task_history_url( @task, @task_history )}
        format.xml  { head :created, :location => task_history_url( @task, @task_history )}
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @task_history.errors.to_xml }
      end
    end
  end

  # PUT /task/{:task_id}/task_histories/1
  # PUT /task/{:task_id}/task_histories/1.xml
  def update
    respond_to do |format|
      if @task_history.update_attributes(params[:task_history])
        flash[:notice] = 'TaskHistory was successfully updated.'
        format.html { redirect_to task_history_url( @task, @task_history )}
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @task_history.errors.to_xml }
      end
    end
  end

  # DELETE /task/{:task_id}/task_histories/1
  # DELETE /task/{:task_id}/task_histories/1.xml
  def destroy
    @task_history.destroy

    respond_to do |format|
      format.html { redirect_to task_histories_url }
      format.xml  { head :ok }
    end
  end

  private
  def get_task
    @task = Task.find( params[ :task_id ])
    @task_history = @task.task_histories.find( params[ :id ]) if params[ :id ]
  end
end