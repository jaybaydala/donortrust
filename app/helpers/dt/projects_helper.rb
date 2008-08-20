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

  def sectors_projects(limit = 4)
    output =[]
    @sectors = Sector.find(:all)
    @sectors.each do |sector|
      output << (link_to image_tag("/images/dt/sectors/#{sector.image_name}",  :title=> sector.name, :alt => sector.name)+" #{sector.name.slice(/\w*\s/)} (#{(sector.projects.size)})", search_dt_projects_path+"?cause_selected=1&sector_id=#{sector.id}") if sector.projects.size>0
    end

    if limit && limit < @sectors.size
      output = output.first(limit).join("<br />")
      output << "<br /><span class='more-button'>...[More]</span>"
      return output
    else
      return output.join("<br />")
    end

  end

  def countries_with_project_counts(limit = 4)
    output =[]
    @countries = Place.find_by_sql("SELECT count(*) as count, p.name as name, p.id as id FROM places p inner join projects pr ON pr.country_id = p.id WHERE pr.project_status_id IN (2,4) AND pr.deleted_at is NULL GROUP BY p.id ORDER BY count DESC")
    @countries.each do |c|
      output << (link_to image_tag("/images/dt/flags/#{c.id}.gif",  :title=> c.name, :alt => c.name)+" #{c.name} (#{(c.count)})", search_dt_projects_path+"?location_selected=1&country_id=#{c.id}") if c.count.to_i>0
    end

    if limit && limit < @countries.size
      output = output.first(limit).join("<br />")
      output << "<br /><span class='more-button'>...[More]</span>"
      return output
    else
      return output.join("<br />")
    end
  end

  def partners_with_projects_count(limit=4)
    output =[]
    @partners = Partner.find_by_sql("SELECT count(*) as count, p.name as name, p.id as id FROM partners p inner join projects pr ON pr.partner_id = p.id WHERE pr.project_status_id IN (2,4) AND pr.deleted_at is NULL AND p.partner_status_id = 1 GROUP BY p.id ORDER BY p.name ASC")
    @partners.each do |p|
      output << link_to("#{p.name} (#{(p.count)})", search_dt_projects_path+"?partner_selected=1&partner_id=#{p.id}") if p.count.to_i>0
    end

    if limit && limit < @partners.size
      output = output.first(limit).join("<br />")
      output << "<br /><span class='more-button'>...[More]</span>"
      return output
    else
      return output.join("<br />")
    end
  end

end
