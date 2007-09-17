class Dt::ProjectsController < DtApplicationController
  # GET /projects
  # GET /projects.xml
  def index
    @projects = Project.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @projects.to_xml }
    end
  end

  # GET /projects/1
  # GET /projects/1.xml
  def show
    @project = Project.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @project.to_xml }
    end
  end

  def search
    redirect_to dt_project_path(params[:project_id]) if params[:project_id]
  end

  def specs
    @project = Project.find(params[:id])
  end

  def village
    @project = Project.find(params[:id])
    @village = @project.urban_centre
  end
  
  def nation
    @project = Project.find(params[:id])
  end
  
  def community
    @project = Project.find(params[:id])
  end
end
