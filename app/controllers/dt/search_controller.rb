class Dt::SearchController < DtApplicationController
  helper "dt/projects"
  def show
    @projects = Project.find_public(:all, search_options)
    @projects = place_filter(@projects) if params[:place_id]
    respond_to do |format|
      format.html
    end
  end

  def search_options
    conditions = ['']
    if params[:partner_id]
      conditions[0] += 'projects.partner_id = ?'
      conditions << params[:partner_id] 
    end
    if params[:cause_id]
      conditions[0] += ' AND ' unless conditions[0].empty?
      conditions[0] += 'causes_projects.cause_id=?'
      conditions << params[:cause_id] 
    end

    order_map = {
      "newest" => "created_at DESC", 
      "target_start_date" => "target_start_date DESC", 
      "budget" => "total_cost DESC", 
      "organization" => "partners.`name` ASC", 
      "place" => "places.`name` ASC"
    }
    order = order_map[params[:order]] if order_map.has_key?(params[:order])
    
    include_map = {
      "organization" => :partner, 
      "place" => :place
    }
    
    include_associations = []
    include_associations << include_map[params[:order]] if include_map.has_key?(params[:order])
    include_associations << :causes if params[:cause_id] 
    
    options = {}
    options[:conditions] = conditions unless conditions[0].empty?
    options[:order] = order if order
    options[:include] = include_associations if include_associations
    options.empty? ? nil : options
  end
  
  def place_filter(projects)
    projects.each_index do |i|
      project = projects[i]
      unless project.place_id? && project.place
        logger.info "NO PLACE ASSOCIATED WITH PROJECT : #{project.name}"
        projects.delete_at(i)
        next
      end
      ancestors_and_self = []
      ancestors_and_self << project.place_id
      project.place.ancestors.each do |ancestor|
        ancestors_and_self << ancestor.id
      end
      logger.info "================================="
      logger.info "PROJECT : #{project.name}"
      logger.info "ANCESTORS : " + ancestors_and_self.join(',')
      projects.delete_at(i) unless ancestors_and_self.include?(params[:place_id])
    end
    projects
  end
end
