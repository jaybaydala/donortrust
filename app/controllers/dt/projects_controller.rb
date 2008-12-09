class Dt::ProjectsController < DtApplicationController
  include RssParser
  before_filter :project_id_to_session, :only=>[:facebook_login]
  before_filter :require_facebook_login, :only=>[:facebook_login]
  before_filter :store_location, :except=>[:facebook_login, :finish_facebook_login, :timeline]
  helper "dt/groups"

  @monkey_patch_flag = false

  def initialize
    @topnav = 'projects'
  end

  def index
    store_location
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
    store_location
    begin
      @project = Project.find_public(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @page_title = @project.name
    @rss_feed = last_rss_entry(@project.rss_url) if @project && @project.rss_url
    @flickr_images = @project.project_flickr_images.paginate({:page => params[:flickr_page], :per_page => 12})
    @youtube_videos = @project.project_you_tube_videos.paginate({:page => params[:youtube_page], :per_page => 6})
    # What is youtube_videos_size used for? 
    @youtube_videos_size = @project.project_you_tube_videos.size if @project.project_you_tube_videos
    @budget_items = @project.budget_items
    #@rss_feed.clean! if @rss_feed # sanitize the html
    @organization = @project.partner
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

  def give
    begin
      @project = Project.find_public(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    respond_to do |format|
      format.html
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

  def list
    @projects = Project.paginate :page => params[:page]
    render :layout => false
  end

  # Ultrasphinx search - First apply filters, then, depending on sorting mode, do the ultrasphinx search
  def search
    @query = params[:keywords].nil? ?  "" : params[:keywords]

    # prepare filters
    filters = apply_filters

    # do the search itself
    ultrasphinx_search(filters)
    params[:filter] = false;

    respond_to do |format|
      format.html { render :partial => 'dt/projects/search_results', :layout => 'layouts/dt_application'}
    end
  end

  # advanced search with ultrasphinx.
  def advancedsearch
    params[:filter] = true;
  end


  # populates the country select using the continent_id
  def add_countries
    projects = Project.find_public(:all, :conditions => ["continent_id=?" params[:continent_id].to_i])
    @countries = [[ 'All ...', '']]
    projects.each do |project|
      sum = 0
      projects.each do |pj|
        sum += 1 if project.country_id==pj.country_id
      end
      name = "#{!project.country_id.nil? ? project.nation.name : project.place.country.name} (#{sum})"
      @countries << [name, project.country_id]
    end
    @countries.uniq!
    respond_to do |format|
      format.js {
        render :update do |page|
          page.replace_html "country_id_container", :partial => "select_countries"
        end
      }
    end
  end
  helper_method :add_countries

  # populates the cause select using the sector_id
  def add_causes
    # pega todas causas com sector_id
    # pra cada causa, veja quantos projetos
    @causes = [['All ...', '']]
    #@search = Ultrasphinx::Search.new(:class_names => ['Project'], :per_page => Project.count, :filters => {:sector_id => params[:sector_id].to_i })
    #@search.run
    #causes = Cause.find_by_sector_id(params[:sector_id]) if params[:sector_id]
    sector = Sector.find(params[:sector_id].to_i)
    sector.causes.each do |cause|
    if cause.sector.id==sector.id && cause.projects.size>0
        @causes << ["#{cause.name} (#{cause.projects.size})", cause.id]
      end
    end
    @causes


    #@search.results.each do |cause|
    #  if cause.projects.size>0
    #    @causes << ["#{cause.name} (#{cause.projects.size})", cause.id]
    #  end
    #end
    respond_to do |format|
      format.js {
        render :update do |page|
          page.replace_html "cause_id_container", :partial => "select_causes"
        end
      }
    end
  end
  helper_method :add_causes

  def get_videos
    begin
      @project = Project.find_public(params[:id])
    rescue ActiveRecord::RecordNotFound
      rescue_404 and return
    end
    @youtube_videos = @project.project_you_tube_videos
    respond_to do |format|
      format.js {
        render :update do |page|
          if @youtube_videos.size>0
            page.replace_html "project_videos", :partial => 'youtube_video' , :collection => @youtube_videos
          else
            page.replace_html "project_videos", '<h2>There are no project videos available at this time.</h2>'
          end
        end
      }
    end
  end


  protected

  def apply_filters
    filters = Hash.new
    # partner
    if params[:partner_selected]
      if !params[:partner_id].nil? && !params[:partner_id].empty?
        filters.merge!({:partner_id => params[:partner_id].to_i})
      end
    end

    # cause
    if params[:cause_selected]
      if !params[:cause_id].nil? && !params[:cause_id].empty?
        filters.merge!({:cause_id => params[:cause_id].to_i} )
      end
    end

    # sector (don't worry about cause_selected)
    if params[:cause_selected]
      if !params[:sector_id].nil? && !params[:sector_id].empty?
        #filters.merge!({:sector_id => params[:sector_id].to_i} )
        sel_projects_sector = []
        sel_projects_sector = Project.find_public( :all, :joins => [:sectors], :conditions => "sectors.id=#{params[:sector_id]}")
      end
    end

    # total_cost
    if params[:funding_req_selected]
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
    end

    #fully funded
    if !params[:fully_funded].nil? && ! params[:fully_funded].empty?
      @search = Ultrasphinx::Search.new(:class_names => 'Project', :per_page => Project.count)
      @search.run
      projects = @search.results
      sel_ff_projects =[]
      projects.each do |project|
        sel_ff_projects << project if project.current_need.to_f<=0.0
      end
      if !sel_ff_projects.nil?
        ids = []
        sel_ff_projects.each do |project|
          ids << project.created_at
        end
        filters.merge!(:created_at => ids)
      end
    end

    if params[:location_selected]
      if !params[:country_id].nil? && !params[:country_id].empty?
        sel_projects = []
        sel_projects = Project.find_public( :all, :conditions => "country_id=#{params[:country_id]}")
      elsif !params[:continent_id].nil? && !params[:continent_id].empty?
          sel_projects = []
          sel_projects = Project.find_public( :all, :conditions => "continent_id=#{params[:continent_id]}")
      end

    end


    # monkey patch to easily and quickly search for location
    unless sel_projects.nil?
      ids = []
      sel_projects.each do |project|
        ids << project.id
      end
      filters.merge!(:project_id => ids)
      #filters.merge!(:created_at => ids)
    end

    # monkey patch to fix sector results
    unless sel_projects_sector.nil?
pp sel_projects_sector.map{|p|p.id}
      ids = []
      sel_projects_sector.each do |project|
        ids << project.id
      end

      filters.merge!(:project_id => ids )
    end

    return filters
  end



  def ultrasphinx_search(filters)

    if params[:order].nil?

      @search = Ultrasphinx::Search.new(:query => @query,:class_names => ['Project'], :sort_by => 'project_status_id',:sort_mode => 'ascending', :filters =>filters, :per_page => 5, :page => (params[:page].nil? ? '1': params[:page]  ))
      Ultrasphinx::Search.excerpting_options = HashWithIndifferentAccess.new({
        :before_match => '<strong style="background-color:yellow;">',
        :after_match => '</strong>',
        :chunk_separator => "...",
        :limit => 256,
        :around => 3,
        :sort_mode => 'relevance' ,
        :weights => {'name' => 10.0, 'place_name'=> 8.0, 'description' => 7.0, 'meas_eval_plan' => 4.0},
        :content_methods => [['name'], ['description'], ['meas_eval_plan'], ['places_name']]
        })

        @search.excerpt

    else
        # order results
        order_map = {
              "newest" => "created_at",
              "target_start_date" => "target_start_date",
              "total_cost" => "total_cost",
              "partner_name" => "partner_name",
              "place_name" => "place_name"
        }

        order = order_map[params[:order]] if order_map.has_key?(params[:order])
        @search = Ultrasphinx::Search.new(:query => @query,:filters =>filters,:class_names => ['Project'], :sort_by => 'project_status_id',:sort_mode => 'ascending',:sort_by => order, :sort_mode => 'ascending',  :per_page => 5,  :page => (params[:page].nil? ? '1': params[:page]  ) )
        Ultrasphinx::Search.excerpting_options = HashWithIndifferentAccess.new({
          :before_match => '<strong style="background-color:yellow;">',
          :after_match => '</strong>',
          :chunk_separator => "...",
          :limit => 256,
          :around => 3,
          :weights => {'name' => 10.0, 'place_name'=> 8.0, 'description' => 7.0, 'meas_eval_plan' => 4.0},
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
