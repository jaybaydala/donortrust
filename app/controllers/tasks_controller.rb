class TasksController < ApplicationController
  before_filter( :get_milestone )

  # GET /milestone/{:milestone_id}/tasks
  # GET /milestone/{:milestone_id}/tasks.xml
  def index
    @tasks = @milestone.tasks

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @tasks.to_xml }
    end
  end

  # GET /milestone/{:milestone_id}/tasks/1
  # GET /milestone/{:milestone_id}/tasks/1.xml
  def show
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @task.to_xml }
    end
  end

  # GET /milestone/{:milestone_id}/tasks/new
  def new
    @task = Task.new
  end

  # GET /milestone/{:milestone_id}/tasks/1;edit
  def edit
  end

  # POST /milestone/{:milestone_id}/tasks
  # POST /milestone/{:milestone_id}/tasks.xml
  def create
    @task = Task.new( params[ :task ])
    @task.milestone_id = params[ :milestone_id ]

    respond_to do |format|
      if @task.save
        flash[:notice] = 'Task was successfully created.'
        format.html { redirect_to task_url( @milestone, @task )}
        format.xml  { head :created, :location => task_url( @milestone, @task )}
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @task.errors.to_xml }
      end
    end
  end

  # PUT /milestone/{:milestone_id}/tasks/1
  # PUT /milestone/{:milestone_id}/tasks/1.xml
  def update
    respond_to do |format|
      if @task.update_attributes(params[:task])
        flash[:notice] = 'Task was successfully updated.'
        format.html { redirect_to task_url( @milestone, @task )}
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @task.errors.to_xml }
      end
    end
  end

  # DELETE /milestone/{:milestone_id}/tasks/1
  # DELETE /milestone/{:milestone_id}/tasks/1.xml
  def destroy
    @task.destroy

    respond_to do |format|
      format.html { redirect_to tasks_url( @milestone ) }
      format.xml  { head :ok }
    end
  end

  private
  def get_milestone
    @milestone = Milestone.find( params[ :milestone_id ])
    @task = @milestone.tasks.find( params[ :id ]) if params[ :id ]
  end
end