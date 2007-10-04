class Dt::ProjectsController < DtApplicationController
  def initialize
    @topnav = 'projects'
  end
  
  def index
    @projects = FeaturedProject.find_projects(:all) if FeaturedProject.count > 0
    # TODO: Project should be order_by Rating once rating model is done
    @projects = Project.find(:all, :limit => 3) if FeaturedProject.count == 0
p "HITHERE"
p @projects
    respond_to do |format|
      format.html # index.rhtml
    end
  end

  def show
    @project = Project.find(params[:id])
    respond_to do |format|
      format.html # show.rhtml
    end
  end

  def specs
    @project = Project.find(params[:id])
  end

  def village
    @project = Project.find(params[:id])
    @village = @project.village
  end
    
  def nation
    @project = Project.find(params[:id])
    @nation = @project.nation
  end
    
  def community
    @project = Project.find(params[:id])
  end
end
