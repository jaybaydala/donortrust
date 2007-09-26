class Dt::ProjectsController < DtApplicationController
  def index
    @projects = FeaturedProject.find_projects(:all) if FeaturedProject.count > 0
    @projects = Project.find(:all, :limit => 3) if FeaturedProject.count == 0
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
end
