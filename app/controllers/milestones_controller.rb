class MilestonesController < ApplicationController
  before_filter( :get_project )

  # GET /project/{:project_id}/milestones
  # GET /project/{:project_id}/milestones.xml
  def index
    @milestones = @project.milestones

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @milestones.to_xml }
    end
  end

  # GET /project/{:project_id}/milestones/:id
  # GET /project/{:project_id}/milestones/{:id}.xml
  def show
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @milestone.to_xml }
    end
  end

  # GET /project/{:project_id}/milestones/new
  def new
    @milestone = Milestone.new
  end

  # GET /project/{:project_id}/milestones/:id;edit
  def edit
  end

  # POST /project/{:project_id}/milestones
  # POST /project/{:project_id}/milestones.xml
  def create
    @milestone = Milestone.new( params[ :milestone ])
    @milestone.project_id = params[ :project_id ]

    respond_to do |format|
      if @milestone.save
        flash[:notice] = 'Milestone was successfully created.'
        format.html { redirect_to milestone_url( @project, @milestone ) }
        format.xml  { head :created, :location => milestone_url( @project, @milestone ) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @milestone.errors.to_xml }
      end
    end
  end

  # PUT /project/{:project_id}/milestones/:id
  # PUT /project/{:project_id}/milestones/{:id}.xml
  def update
    @milestone = Milestone.find( params[ :id ])

    respond_to do |format|
      if @milestone.update_attributes( params[ :milestone ])
        flash[ :notice ] = 'Milestone was successfully updated.'
        format.html { redirect_to milestone_url( @project, @milestone ) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @milestone.errors.to_xml }
      end
    end
  end

  # DELETE /project/{:project_id}/milestones/:id
  # DELETE /project/{:project_id}/milestones/{:id}.xml
  def destroy
    @milestone.destroy

    respond_to do |format|
      format.html { redirect_to milestones_url( @project ) }
      format.xml  { head :ok }
    end
  end
  
  private
  def get_project
    raise "no route" if ! params[ :project_id ]
    @project = Project.find( params[ :project_id ])
    @milestone = @project.milestones.find( params[ :id ]) if params[ :id ]
  end
end
