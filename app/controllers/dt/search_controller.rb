class Dt::SearchController < DtApplicationController
  helper "dt/projects"
  def show
    @projects = Project.find_public(:all, search_options)
    @projects = place_filter(@projects) if params[:place_id] && Place.exists?(params[:place_id])
    @projects = @projects.paginate({:page => params[:page], :per_page => 5})
    @place = Place.find(params[:place_id]) if params[:place_id] && Place.exists?(params[:place_id])
    @partner = Partner.find(params[:partner_id]) if params[:partner_id] && Partner.exists?(params[:partner_id])
    @cause = Cause.find(params[:cause_id]) if params[:cause_id] && Cause.exists?(params[:cause_id])
    if @projects.size == 0
      @featured_projects = Project.featured_projects
    end
    respond_to do |format|
      format.html
    end
  end

  def bar
    respond_to do |format|
      format.html { render :layout => false}
    end
  end

  protected
  def search_options
    conditions = ['']
    if params[:partner_id] && !params[:partner_id].empty?
      conditions[0] += 'projects.partner_id = ?'
      conditions << params[:partner_id] 
    end
    if params[:cause_id] && !params[:cause_id].empty?
      conditions[0] += ' AND ' unless conditions[0].empty?
      conditions[0] += 'causes_projects.cause_id=?'
      conditions << params[:cause_id] 
    end

    order_map = {
      "newest" => "created_at DESC", 
      "date" => "target_start_date ASC", 
      "budget" => "total_cost DESC", 
      "organization" => "partners.`name` ASC", 
      "place" => "places.`name` ASC"
    }
    params[:order] = 'newest' if !params[:order]
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
    projects = projects.delete_if do |project|
      if !project.place_id? || !project.place
        true
      else
        @ancestors_and_self_ids = []
        @ancestors_and_self_ids << project.place_id
        project.place.ancestors.each do |ancestor|
          @ancestors_and_self_ids << ancestor.id
        end
        # delete if it's not included
        !@ancestors_and_self_ids.include?(params[:place_id].to_i)
      end
    end
    projects
  end
end
