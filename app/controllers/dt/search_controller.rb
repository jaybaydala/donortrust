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
    conditions = {}
    conditions[:partner_id] = params[:partner_id] if params[:partner_id]
    conditions[:cause_id] = params[:cause_id] if params[:cause_id]

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
    include_association = include_map[params[:order]] if include_map.has_key?(params[:order])
    
    options = {}
    options[:conditions] = conditions unless conditions.empty?
    options[:order] = order if order
    options[:include] = include_association if include_association
    options.empty? ? nil : options
  end
  
  def place_filter(projects)
    projects.each_index do |i|
      project = projects[i]
      logger.info "NO PLACE ASSOCIATED WITH PROJECT : #{project.name}" unless project.place_id? && project.place
      projects.delete_at(i) and break unless project.place_id? && project.place
      ancestors_and_self = []
      ancestors_and_self << project.place_id
      project.place.ancestors.each do |ancestor|
        ancestors_and_self << ancestor.id
      end
      projects.delete_at(i) unless ancestors_and_self.include?(params[:place_id])
    end
    projects
  end
end
