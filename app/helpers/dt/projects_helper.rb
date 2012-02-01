module Dt::ProjectsHelper
  def project_nav
    render :file => 'dt/projects/project_nav'
  end

  def mdg_goals
    if @mdgs
      render :file => 'dt/shared/mdg_goals'
    end
  end

  def project_actions
    render :file => 'dt/projects/project_actions'
  end

  def project_quickfacts
    render :file => 'dt/projects/project_quickfacts'
  end

  def project_search_quickfacts
    render :file => 'dt/projects/project_search_quickfacts'
  end

  def current_member(group, user = current_user)
    @current_member ||= group.memberships.find_by_user_id(user) if user
  end

  def community_projects(project)
    if @community_projects.nil?
      @community_projects = []
      unless @project.community.nil? || @project.community.projects.nil?
        projects = Project.for_country(country_code).find_public(:all, :select => 'projects.name, projects.id', :conditions => ['projects.place_id = ? AND projects.id != ?', project.community_id, project.id])
        @community_projects = projects.collect do |project|
          [project.name, project.id]
        end
      end
    end
    @community_projects
  end

  # def countries_with_project_counts(limit = 4)
  #   output =[]
  #   @countries = Place.find_by_sql(
  #       "SELECT count(*) as count, p.name as name, p.id as id "+
  #       "FROM (SELECT * FROM partners WHERE partner_status_id=1) pa INNER JOIN projects pr INNER JOIN places p "+
  #       "ON pa.id = pr.partner_id AND pr.country_id = p.id "+
  #       "WHERE pr.project_status_id IN (2,4) AND pr.deleted_at is NULL AND pa.id != 4 "+
  #       "GROUP BY p.id ORDER BY count DESC")
  #   @countries.each do |c|
  #     output << (link_to "#{c.name} (#{(c.count)})", search_dt_projects_path+"?location_selected=1&country_id=#{c.id}") if c.count.to_i>0
  #   end
  # 
  #   if limit && limit < @countries.size
  #     output = output.first(limit).join("<br />")
  #     output << "<br /><span class='more-button'>...[More]</span>"
  #     return output
  #   else
  #     return output.join("<br />")
  #   end
  # end

  # def partners_with_projects_count(limit=4)
  #   output =[]
  #   @partners = Partner.find_by_sql(
  #       "SELECT count(*) as count, p.name as name, p.id as id "+
  #       "FROM partners p INNER JOIN projects pr ON pr.partner_id = p.id " +
  #       "WHERE pr.project_status_id IN (2,4) AND pr.deleted_at is NULL AND p.id != 4 " +
  #       "AND p.partner_status_id = 1 GROUP BY p.id ORDER BY p.name ASC")
  #   @partners.each do |p|
  #     output << link_to("#{truncate(p.name, :length => 20)} (#{(p.count)})", search_dt_projects_path+"?partner_selected=1&partner_id=#{p.id}") if p.count.to_i>0
  #   end
  # 
  #   if limit && limit < @partners.size
  #     output = output.first(limit).join("<br />")
  #     output << "<br /><span class='more-button'>...[More]</span>"
  #     return output
  #   else
  #     return output.join("<br />")
  #   end
  # end

  def total_project_budget_items(items)
    sum = 0.0
    items.each do |item|
      sum+=item.cost
    end
    return number_to_currency(sum)
  end

  def total_cost_with_project_count(minimum=0, maximum=100000)
    output = []
    #@range = Ultrasphinx::Search.new(:filters  => {:total_cost => minimum..maximum}, :per_page  => Project.count, :class_names => ['Project'])

    #@partners.each do |p|
    #  output << link_to("#{truncate(p.name,20)} (#{(p.count)})", search_dt_projects_path+"?partner_selected=1&partner_id=#{p.id}") if p.count.to_i>0
    #end

    #if @range.run
    #  output << link_to("$ #{minimum} - $ #{maximum} (#{@range.run.size})", search_dt_projects_path+"?funding_req_selected=1&funding_req_min=#{minimum}&funding_req_max=#{maximum}" ) + "<br/>"
    #end

    projectcount =  Project.find_by_sql([
        "SELECT count(*) as count FROM partners p INNER JOIN projects pr ON pr.partner_id = p.id "+
        "WHERE pr.project_status_id IN (2,4) AND pr.deleted_at is NULL AND p.id != 4 "+
        "AND p.partner_status_id = 1 AND pr.total_cost >= ? AND pr.total_cost <= ?;",minimum, maximum])

    if projectcount[0].count.to_i > 0
      output = link_to("$ #{minimum} - $ #{maximum} (#{projectcount[0].count})", search_dt_projects_path+"?funding_req_selected=1&funding_req_min=#{minimum}&funding_req_max=#{maximum}" ) + "<br/>"
    end

    return output

  end

  def flickr_slider
    if @flickr_images.size > 0
      render :partial  => 'flickr_slider'
  	end
  end

  def milestone_date(date)
    date.strftime("%B %Y")
  end
end
