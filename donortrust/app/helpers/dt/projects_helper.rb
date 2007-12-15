module Dt::ProjectsHelper
  def project_nav
    render 'dt/projects/project_nav'
  end

  def mdg_goals
    if @mdgs
      render 'dt/shared/mdg_goals'
    end
  end
  
  def project_actions
    render 'dt/projects/project_actions'
  end

  def project_quickfacts
    render 'dt/projects/project_quickfacts'
  end

  def project_search_quickfacts
    render 'dt/projects/project_search_quickfacts'
  end

  def current_member(group, user = current_user)
    @current_member ||= group.memberships.find_by_user_id(user) if user
  end
  
  def community_projects(project)
    if @community_projects.nil?
      @community_projects = []
      unless @project.community.nil? || @project.community.projects.nil?
        projects = Project.find_public(:all, :select => 'projects.name, projects.id', :conditions => ['projects.place_id = ? AND projects.id != ?', project.community_id, project.id])
        @community_projects = projects.collect do |project|
          [project.name, project.id]
        end
      end
    end
    @community_projects
  end
end
