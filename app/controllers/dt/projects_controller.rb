class Dt::ProjectsController < DtApplicationController
  include RssParser
  before_filter :project_id_to_session, :only=>[:facebook_login]
  before_filter :require_facebook_login, :only=>[:facebook_login]
  before_filter :store_location, :except=>[:facebook_login, :finish_facebook_login, :timeline]
  helper "dt/groups"

  def initialize
    @topnav = 'projects'
  end
  
  def index
    @page_title = 'Featured Projects'
    @projects = Project.featured_projects
    respond_to do |format|
      format.html
    end
  end
  
  # for sitemap.xml google sitemap functionality for projects
  #def sitemap
  #  @projects = Project.find_public(:all)
  #  respond_to do |format|
  #    format.xml {
  #      render :file => "#{RAILS_ROOT}/app/views/dt/projects/sitemap.rxml"
  #    }
  #  end
  #end

  def show
    begin
      @project = Project.find_public(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @page_title = @project.name
    @rss_feed = last_rss_entry(@project.rss_url) if @project && @project.rss_url
    @flickr_images = @project.project_flickr_images.paginate({:page => params[:flickr_page], :per_page => 12})
    @youtube_videos = @project.project_you_tube_videos.paginate({:page => params[:youtube_page], :per_page => 6})
    #@rss_feed.clean! if @rss_feed # sanitize the html
    respond_to do |format|
      format.html
    end
  end

  def details
    begin
      @project = Project.find_public(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @page_title = "Project Details | #{@project.name}"
    @action_js = "http://simile.mit.edu/timeline/api/timeline-api.js"
    respond_to do |format|
      format.html
    end
  end

  def community
    begin
      @project = Project.find_public(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @community = @project.community
    @page_title = "#{@community.name} | #{@project.name}"
    
    @mdgs = MillenniumGoal.find(:all)
    @rss_feed = last_rss_entry(@project.community.rss_url) if @project && @project.community.rss_url?
    #@rss_feed.clean! if @rss_feed # sanitize the html
    respond_to do |format|
      format.html
    end
  end
    
  def nation
    begin
      @project = Project.find_public(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @nation = @project.nation
    @page_title = "#{@nation.name} | #{@project.name}"
    @mdgs = MillenniumGoal.find(:all)
    respond_to do |format|
      format.html
    end
  end
  
  def organization
    begin
      @project = Project.find_public(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @organization = @project.partner if @project.partner_id?
    @page_title = "#{@organization.name} | #{@project.name}"
    respond_to do |format|
      format.html
    end
  end
    
  def connect
    begin
      @project = Project.find_public(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @public_groups = @project.public_groups.paginate({:page => params[:page], :per_page => 10})
    @page_title = "Connect | #{@project.name}"

    integrate_facebook
    respond_to do |format|
      format.html
    end
  end

  def cause
    begin
      @project = Project.find_public(params[:id])
      @cause = Cause.find(params[:cause_id]) if params[:cause_id]
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    respond_to do |format|
      format.html {render :action => 'cause', :layout => 'dt/plain'}
    end
  end
  
  def facebook_login
    # placeholder for the before_filters above: project_id_to_session, facebook_login
    # is there a more elegant way to do this? 
    # project_id_to_session: stores the project id in the (surprise) session, 
    # require_facebook_login is a rfacebook thing that bounces the user to facebook, gets a session id, and stores it in the rails session, makes the fbsession object available to controllers
  end
  def finish_facebook_login
    project_id = session[:project_id]
    session[:project_id] = nil
    respond_to do |format|
      # TODO: translate to the hash format
      # :action => 'connect', :id=>session[:project_id] 
      format.html { redirect_to dt_connect_project_path(project_id) }
    end
  end

  def timeline
    @project = Project.find(params[:id])
    @milestones = @project.milestones(:include => :tasks)
    @tasks = @project.tasks  #Task.find(:all, :joins=>['INNER Join milestones on tasks.milestone_id = milestones.id'], :conditions=> ['milestones.project_id = ?', @id])
    render :partial => 'timeline'
  end
  
  def search
    @query = params[:keywords].nil? ?  "" : params[:keywords] 
    
    #apply filters
    filters = apply_filters
   
   # order results
    order_map = {
        "newest" => "created_at", 
        "target_start_date" => "target_start_date", 
        "total_cost" => "total_cost", 
        "partner_name" => "partners.`name`", 
        "place_name" => "places.`name`"
      }
    
    # do the search
    ultrasphinx_search(filters)
    
    respond_to do |format|
      format.js{
        render :update do |page|
          page.replace_html "count_results_container", "#{@search.total_entries } results found"
        end
      }
      format.html { render :partial => 'dt/projects/search_results', :layout => 'layouts/dt_application'}
    end
  end

  # deprecated
  def search_old
    #@query = params[:keywords]
    
    #if params[:filter]
      # performs filtering on results
    #  filter_search
    #else
    #  # ultrasphinx (fast response)
    #  ultrasphinx_search
    #end
    #respond_to do |format|
    #  format.js{
    #    render :update do |page|
    #      page.replace_html "count_results_container", "#{@search.total_entries } results found"
    #    end
    #  }
    #  format.html { render :partial => 'dt/projects/search_results', :layout => 'layouts/dt_application'}
    #end
  end
  
  #populates a select using the continent_id
  def add_countries
    places = Place.find(:all, :conditions => [ "parent_id = ?", params[:continent_id]] )
    @countries = [['Location', '']]
    places.each do |country|
      projects = Place.projects(2,country.id)
      if projects.size>0
        name = country.parent_id? ? "#{country.name} (#{projects.size})" : "#{country.name} (#{projects.size})"
        @countries << [name, country.id]
      end
    end
    respond_to do |format|
      format.js {
        render :update do |page|
          page.replace_html "country_id_container", :partial => "select_countries"
        end
      }
    end
  end


  protected  
  
  def apply_filters
    filters = Hash.new
    
    # partner
    if !params[:partner_id].nil? && !params[:partner_id].empty?
      filters.merge!({:partner_id => params[:partner_id].to_i})
    end
    
    # cause 
    if !params[:cause_id].nil? && !params[:cause_id].empty?
      filters.merge!({:cause_id => params[:cause_id].to_i} )
    end
    
    # total_cost
    if (!params[:funding_req_min].nil? && !params[:funding_req_min].empty?)|| (!params[:funding_req_max].nil? && !params[:funding_req_max].empty?)
      
      if !params[:funding_req_max].nil? && !params[:funding_req_max].empty?
        
        if !params[:funding_req_min].nil? && !params[:funding_req_min].empty?
          filters.merge!(:total_cost => params[:funding_req_min].to_f..params[:funding_req_max].to_f)
        else
          filters.merge!(:total_cost => 0..params[:funding_req_max].to_f)
        end
        
      else
        if !params[:funding_req_min].nil? && !params[:funding_req_min].empty?
          filters.merge!(:total_cost => params[:funding_req_min].to_f..Float::MAX.to_f)
        end
       
      end
    end
    

    if !params[:continent_id].nil? && !params[:continent_id].empty? && !params[:country_id].nil? && !params[:country_id].empty?
      sel_projects = []
      sel_projects = Place.projects(2, params[:country_id].to_i)
      
    else
      if !params[:continent_id].nil? && !params[:continent_id].empty?
        sel_projects = []
        sel_projects = Place.projects(1, params[:continent_id].to_i)        
      end
    end
    
    if !sel_projects.nil?
      ids = []
      sel_projects.each do |project|  
        ids << project.place_id
      end
      filters.merge!(:place_id => ids)
    end
    return filters
  end
  
  # deprecated
  def filter_search
    #conditions = ['1=1']
    #if !params[:partner_id].nil? && !params[:partner_id].empty?
    #  conditions << "projects.partner_id = #{params[:partner_id]}"
    #end
    #if !params[:cause_id].nil? && !params[:cause_id].empty?
    #  conditions << "causes_projects.cause_id = #{params[:cause_id]}"
    #end
    #if (!params[:funding_req_min].nil? && !params[:funding_req_min].empty?)|| (!params[:funding_req_max].nil? && !params[:funding_req_max].empty?)
    #  if !params[:funding_req_max].nil? && !params[:funding_req_max].empty?
    #    conditions << "projects.total_cost <= #{params[:funding_req_max]}"
    #  end
    #  if !params[:funding_req_min].nil? && !params[:funding_req_min].empty?
    #    conditions << "projects.total_cost >= #{params[:funding_req_min]}"
    #  end
    #end
    
    #if (!params[:funding_rec_min].nil? && !params[:funding_rec_min].empty?)|| (!params[:funding_rec_max].nil? && !params[:funding_rec_max].empty?)
    #  if !params[:funding_rec_max].nil? && !params[:funding_rec_max].empty?
    #    conditions << "investments.amount <= #{params[:funding_rec_max]}"
    #  end
    #  if !params[:funding_rec_min].nil? && !params[:funding_rec_min].empty?
    #    conditions << "investments.amount >= #{params[:funding_rec_min]}"
    #  end
    #end
    #if !params[:country][:place_id].empty?
    #    conditions << "places.id = #{params[:country][:place_id]}"
    #else
    #  if !params[:continent][:place_id].empty?
    #    conditions << "places.id = #{params[:continent][:place_id]}"
    #  end
    #end
    
    #if !params[:start_date].nil? && !params[:start_date].empty?
    #  if params[:start_date]=='bigger'
    #    conditions << "projects.target_start_date >= '#{params[:start_date_year]}-#{params[:start_date_month]}-#{params[:start_date_day]}'"
    #  end
    #  if params[:start_date]=='lower'
    #    conditions << "projects.target_start_date <= '#{params[:start_date_year]}-#{params[:start_date_month]}-#{params[:start_date_day]}'"
    #  end
    # end
    
    # order_map = {
    #    "newest" => "created_at", 
    #    "target_start_date" => "target_start_date", 
    #    "total_cost" => "total_cost", 
    #    "partner_name" => "partners.`name`", 
    #    "place_name" => "places.`name`"
    #  }
    #  params[:order] = 'newest' if !params[:order]
    #  order = order_map[params[:order]] if order_map.has_key?(params[:order])
 
      
    #@projects = Project.find_public(:all, 
    #  :joins => 'LEFT JOIN causes_projects on causes_projects.project_id = projects.id LEFT JOIN places ON places.id = projects.place_id LEFT JOIN partners ON partners.id = projects.partner_id' , 
    #  :conditions=> [conditions.join(" AND ")] ,
    #  :group =>'projects.id',
    #  :select => "projects.*, partners.name, places.name")
    

    #@search = Project.paginate( @projects, :page => (params[:page].nil? ? '1': params[:page]  ), :per_page => 5)
    
  end

  def ultrasphinx_search(filters)
    if params[:order].nil?
      @search = Ultrasphinx::Search.new(:query => @query, :sort_by => 'project_status_id',:sort_mode => 'ascending', :filters =>filters, :per_page => 5, :page => (params[:page].nil? ? '1': params[:page]  ) )
      Ultrasphinx::Search.excerpting_options = HashWithIndifferentAccess.new({
        :before_match => '<strong style="background-color:yellow;">',
        :after_match => '</strong>',
        :chunk_separator => "...",
        :limit => 256,
        :around => 3,
        :sort_mode => 'relevance' ,
        :weights => {'name' => 10.0, 'places_name'=> 8.0, 'description' => 7.0, 'meas_eval_plan' => 4.0},
        :content_methods => [['name'], ['description'], ['meas_eval_plan'], ['places_name']]
        })
        @search.excerpt
      else
        @search = Ultrasphinx::Search.new(:query => @query,:filters =>filters, :sort_by => params[:order], :sort_mode => 'ascending', :sort_by => 'project_status_id',:sort_mode => 'ascending', :per_page => 5,  :page => (params[:page].nil? ? '1': params[:page]  ) )
        Ultrasphinx::Search.excerpting_options = HashWithIndifferentAccess.new({
          :before_match => '<strong style="background-color:yellow;">',
          :after_match => '</strong>',
          :chunk_separator => "...",
          :limit => 256,
          :around => 3,
          :weights => {'name' => 10.0, 'places_name'=> 8.0, 'description' => 7.0, 'meas_eval_plan' => 4.0},
          :content_methods => [['name'], ['description'], ['meas_eval_plan'], ['places_name']]
          })
          @search.excerpt      
      end    
  end

  
  def project_id_to_session
    logger.debug '#####################'
    logger.debug 'FACEBOOK PROJECT_ID'
    logger.debug session[:project_id]
    session[:project_id] = params[:id]
    logger.debug session[:project_id]
  end

  def integrate_facebook
    if @project.place and @project.place.facebook_group_id?
      @fb_group_available = true
      @facebook_group_link = "http://www.facebook.com/group.php?gid=#{@project.place.facebook_group_id}"
      if fbsession and fbsession.is_valid?:
        gid = @project.place.facebook_group_id
        @fbid = fbsession.users_getLoggedInUser()
        begin
          @fb_group = fbsession.groups_get(:gids=>gid)
          @fb_user = fbsession.users_getInfo(:uids=>@fbid, :fields=>["name"]).user_list[0]
          members_results = fbsession.groups_getMembers(:gid=>gid)
          # weird! api seems to have bug: cannot do member.uid from group results, have to jump thru hoops
          member_ids = members_results.search("//uid").map{|uidNode| uidNode.inner_html.to_i}
          members = fbsession.users_getInfo(:uids=>member_ids, :fields=>["name","pic_square", "pic", "pic_small"]).user_list
          @fb_members = members.paginate({:page => params[:fb_page], :per_page => 24})
          @fb_user_in_group = true if member_ids.find{ |id| Integer(@fbid.to_s)==id}
        rescue
          @fb_group_available = false
        end
      end
    end
  end
end
